RSpec.configure do |config|
  config.before(:suite) do
    CarrierWave.root = Rails.root.join('spec/carrierwave')
  end

  config.after(:suite) do
    FileUtils.rm_rf(Rails.root.join('spec/carrierwave'))
  end
end
