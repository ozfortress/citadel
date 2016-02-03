require 'steam_id'

describe SteamId do
  let(:textual) { 'STEAM_0:1:38631916' }
  let(:int64)   { 76_561_198_037_529_561 }

  it 'Converts from textual to int64 representation' do
    i = described_class.from_str(textual)

    expect(i).to eq(int64)
  end

  it 'Converts from int64 to textual representation' do
    t = described_class.to_str(int64)

    expect(t).to eq(textual)
  end
end
