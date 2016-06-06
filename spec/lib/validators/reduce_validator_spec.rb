require 'rails_helper'
require 'support/shoulda'
require 'validators/reduce_validator'

describe ReduceValidator do
  let(:reduce_validator) { ReduceValidator.new(attributes: [:name]) }

  subject { User.new }

  before(:each) do
    subject.errors.add(:name, 'message one')
    subject.errors.add(:name, 'message two')
  end

  it { expect(subject.errors[:name].size).to eq(2) }

  it 'should reduce error messages' do
    reduce_validator.validate_each(subject, :name, '')
    expect(subject.errors[:name].size).to eq(1)
  end
end
