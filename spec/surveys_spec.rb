require 'spec_helper'

describe Survey do
  it { should have_many :questions }
  it { should validate_uniqueness_of :name}
end
