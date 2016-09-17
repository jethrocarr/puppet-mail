require 'spec_helper'
describe 'mail' do

  context 'with defaults for all parameters' do
    it { should contain_class('mail') }
  end
end
