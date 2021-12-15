require 'rails_helper'

RSpec.describe CookieController, type: :controller do
  context 'create' do
    it 'should set token in cookies' do
      post :create, params: { token: 'asdhakdakjjdsadaj' }
      data = JSON.parse(response.body)['success']
      expect(data).to eq(true)
      expect(cookies.signed[:jwt]).to eq('asdhakdakjjdsadaj')
    end
  end

  context 'signin' do
    before do
      @vendor = create(:vendor)
      @user = create(:user, email: 'test@testvendor.co', password: '123456', vendor: @vendor)
    end

    it 'should login user in system with email and password' do
      post :signin, params: { email: 'test@testvendor.co', password: '123456' }
      data = JSON.parse(response.body)['success']
      expect(data).to eq(true)
      expect(cookies.signed[:jwt]).not_to be_nil
      expect(@user.reload.sign_in_count).to eq(1)
      expect(@user.last_sign_in_ip).to be_nil
      expect(@user.last_sign_in_at).to be_nil
      expect(@user.current_sign_in_ip).to eq('0.0.0.0')
      expect(@user.current_sign_in_at).not_to be_nil

      post :signin, params: { email: 'test@testvendor.co', password: '123456' }
      expect(JSON.parse(response.body)['success']).to eq(true)
      expect(cookies.signed[:jwt]).not_to be_nil
      expect(@user.reload.sign_in_count).to eq(2)
      expect(@user.current_sign_in_ip).to eq('0.0.0.0')
      expect(@user.last_sign_in_ip).to eq('0.0.0.0')
      expect(@user.current_sign_in_at).not_to be_nil
      expect(@user.last_sign_in_at).not_to be_nil
    end

    it 'should not login user in system with incorrect email' do
      post :signin, params: { email: 'test@testvendoasdasdasdr.co', password: '123456' }
      error = JSON.parse(response.body)['error']
      expect(error).to eq('Incorrect username or password')
      expect(cookies.signed[:jwt]).to be_nil
    end

    it 'should not login user in system with incorrect password' do
      post :signin, params: { email: 'test@testvendor.co', password: '*****' }
      error = JSON.parse(response.body)['error']
      expect(error).to eq('Incorrect username or password')
      expect(cookies.signed[:jwt]).to be_nil
    end

    it 'should not login user in system with invalid params' do
      post :signin, params: {}
      error = JSON.parse(response.body)['error']
      expect(error).to eq('Insufficient params provided')
      expect(cookies.signed[:jwt]).to be_nil

      post :signin, params: { email: 'test@testvendor.co' }
      error = JSON.parse(response.body)['error']
      expect(error).to eq('Insufficient params provided')
      expect(cookies.signed[:jwt]).to be_nil

      post :signin, params: { password: '*****' }
      error = JSON.parse(response.body)['error']
      expect(error).to eq('Insufficient params provided')
      expect(cookies.signed[:jwt]).to be_nil
    end
  end
end
