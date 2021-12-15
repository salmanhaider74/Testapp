# To Run: OneOffs::UpdateOrdersVartanaRating.run
module OneOffs
  class UpdateOrdersVartanaRating
    def self.run
      ids = [16, 17]
      Order.where(id: ids).each do |o|
        o.update(vartana_rating: vartana_rating(o.vartana_score), manual_review: true)
      end
    end

    def self.vartana_rating(score)
      rating = :missing
      @point_system_config = YAML.load_file(Rails.root.join('lib', 'underwriting', 'vps_v1.yml'))

      @point_system_config['configs']['ratings'].each do |fs|
        rating = fs['rating'] if fs['range'].include?(score)
      end

      rating
    end
  end
end
