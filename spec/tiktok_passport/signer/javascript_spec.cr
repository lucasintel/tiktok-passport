require "../../spec_helper"

describe TiktokPassport::Signer::Javascript do
  describe ".sign" do
    it "returns the sign function" do
      result = TiktokPassport::Signer::Javascript.sign("http://tiktok.com")
      result.should eq(
        <<-JS
          return byted_acrawler.sign({ url: "http://tiktok.com" });
        JS
      )
    end
  end
end
