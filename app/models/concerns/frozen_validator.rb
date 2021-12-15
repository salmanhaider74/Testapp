class FrozenValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    record.errors.add(attribute, 'cannot be changed') if record.changes.include?(attribute)
  end
end
