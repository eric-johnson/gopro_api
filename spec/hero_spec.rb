require 'spec_helper'

describe Hero do
  let( :transit ) {}

  subject {
    described_class.new transit, "abc123"
  }

  before :each do
    allow( transit ).to receive( :get )
  end

  it "generates the on URI" do
    expected_uri = URI("http://10.5.5.9:80/bacpac/PW?t=abc123&p=%01")
    subject.power_on!
    expect( transit ).to have_received( :get ).with( expected_uri )
  end

end
