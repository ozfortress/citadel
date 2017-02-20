require 'steam_id'

describe SteamId do
  let(:steam_32) { 'STEAM_0:1:38631916' }
  let(:steam_64)  { 76_561_198_037_529_561 }
  let(:steam_id3) { 'U:1:77263833' }

  it '#valid_32?' do
    expect(described_class.valid_32?(steam_32)).to be_truthy

    expect(described_class.valid_32?('STEAM_1:1:09342341')).to be_falsey
    expect(described_class.valid_32?(steam_64)).to be_falsey
    expect(described_class.valid_32?(steam_id3)).to be_falsey
  end

  it '#valid_64?' do
    expect(described_class.valid_64?(steam_64)).to be_truthy

    expect(described_class.valid_64?('123abc')).to be_falsey
    expect(described_class.valid_64?(steam_32)).to be_falsey
    expect(described_class.valid_64?(steam_id3)).to be_falsey
  end

  it '#valid_id3?' do
    expect(described_class.valid_id3?(steam_id3)).to be_truthy

    expect(described_class.valid_id3?('U:0:12387634')).to be_falsey
    expect(described_class.valid_id3?(steam_32)).to be_falsey
    expect(described_class.valid_id3?(steam_64)).to be_falsey
  end

  it '#to_32' do
    expect(described_class.to_32(steam_32)).to eq(steam_32)
    expect(described_class.to_32(steam_64)).to eq(steam_32)
    expect(described_class.to_32(steam_id3)).to eq(steam_32)
    expect(described_class.to_32('garbage')).to be_nil
  end

  it '#to_64' do
    expect(described_class.to_64(steam_32)).to eq(steam_64)
    expect(described_class.to_64(steam_64)).to eq(steam_64)
    expect(described_class.to_64(steam_id3)).to eq(steam_64)
    expect(described_class.to_64('garbage')).to be_nil
  end

  it '#to_id3' do
    expect(described_class.to_id3(steam_32)).to eq(steam_id3)
    expect(described_class.to_id3(steam_64)).to eq(steam_id3)
    expect(described_class.to_id3(steam_id3)).to eq(steam_id3)
    expect(described_class.to_id3('garbage')).to be_nil
  end
end
