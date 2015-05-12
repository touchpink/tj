describe ThemeJuice::Config do

  before :each do
    @config = ThemeJuice::Config
    expect_any_instance_of(@config).to receive(:config)
      .once.and_return YAML.load %Q{
commands:
  install:
    - echo "%args%"
  watch: echo "%arguments%"
  vendor:
    - echo "1:%arg1% 2:%arg2%"
    - echo "3:%arg3% 4:%arg4%"
  wp:
    - echo "1:%argument1% 2:%argument2%"
  backup:
    - echo "1:%argument1% 4:%argument4%"
  dist:
    - echo "1:%argument1% 2:%argument2% 3:%argument3% 4:%argument4%"
}
  end

  describe "#method_missing" do
    context "when receiving an unknown message" do

      it "should not raise error if message exists in config" do
        allow(stdout).to receive(:print)
        expect { @config.install }.not_to raise_error
      end

      it "should raise error if message does not exist in config" do
        allow(stdout).to receive(:print)
        expect { @config.invalid }.to raise_error NotImplementedError
      end

      it "should raise error if config is invalid" do
        allow(stdout).to receive(:print)
        expect { @config.watch }.to raise_error SyntaxError
      end
    end
  end
end