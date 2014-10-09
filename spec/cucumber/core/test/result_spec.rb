# -*- encoding: utf-8 -*-
require 'cucumber/core/test/result'
require 'cucumber/core/test/duration_matcher'

module Cucumber::Core::Test
  describe Result do

    let(:visitor) { double('visitor') }
    let(:args)    { double('args')    }

    describe Result::Passed do
      subject(:result) { Result::Passed.new(duration) }
      let(:duration)   { 1 * 1000 * 1000 }

      it "describes itself to a visitor" do
        expect( visitor ).to receive(:passed).with(args)
        expect( visitor ).to receive(:duration).with(a_duration_of(duration), args)
        result.describe_to(visitor, args)
      end

      it "converts to a string" do
        expect( result.to_s ).to eq "✓"
      end

      it "has a duration" do
        expect( result.duration ).to be_duration duration
      end

      it "requires the constructor argument" do
        expect { Result::Passed.new }.to raise_error(ArgumentError)
      end

      it { expect( result ).to     be_passed    }
      it { expect( result ).not_to be_failed    }
      it { expect( result ).not_to be_undefined }
      it { expect( result ).not_to be_unknown   }
      it { expect( result ).not_to be_skipped   }
    end

    describe Result::Failed do
      subject(:result) { Result::Failed.new(duration, exception) }
      let(:duration)   { 1 * 1000 * 1000 }
      let(:exception)  { StandardError.new("error message") }

      it "describes itself to a visitor" do
        expect( visitor ).to receive(:failed).with(args)
        expect( visitor ).to receive(:duration).with(a_duration_of(duration), args)
        expect( visitor ).to receive(:exception).with(exception, args)
        result.describe_to(visitor, args)
      end

      it "has a duration" do
        expect( result.duration ).to be_duration duration
      end

      it "requires both constructor arguments" do
        expect { Result::Failed.new }.to raise_error(ArgumentError)
        expect { Result::Failed.new(duration) }.to raise_error(ArgumentError)
      end

      it { expect( result ).not_to be_passed    }
      it { expect( result ).to     be_failed    }
      it { expect( result ).not_to be_undefined }
      it { expect( result ).not_to be_unknown   }
      it { expect( result ).not_to be_skipped   }
    end

    describe Result::Unknown do
      subject(:result) { Result::Unknown.new }

      it "doesn't describe itself to a visitor" do
        visitor = double('never receives anything')
        result.describe_to(visitor, args)
      end

      it { expect( result ).not_to be_passed    }
      it { expect( result ).not_to be_failed    }
      it { expect( result ).not_to be_undefined }
      it { expect( result ).to     be_unknown   }
      it { expect( result ).not_to be_skipped   }
    end

    describe Result::Undefined do
      subject(:result) { Result::Undefined.new }

      it "describes itself to a visitor" do
        expect( visitor ).to receive(:undefined).with(args)
        expect( visitor ).to receive(:duration).with(an_unknown_duration, args)
        result.describe_to(visitor, args)
      end

      it { expect( result ).not_to be_passed    }
      it { expect( result ).not_to be_failed    }
      it { expect( result ).to     be_undefined }
      it { expect( result ).not_to be_unknown   }
      it { expect( result ).not_to be_skipped   }
    end

    describe Result::Skipped do
      subject(:result) { Result::Skipped.new }

      it "describes itself to a visitor" do
        expect( visitor ).to receive(:skipped).with(args)
        expect( visitor ).to receive(:duration).with(an_unknown_duration, args)
        result.describe_to(visitor, args)
      end

      it { expect( result ).not_to be_passed    }
      it { expect( result ).not_to be_failed    }
      it { expect( result ).not_to be_undefined }
      it { expect( result ).not_to be_unknown   }
      it { expect( result ).to     be_skipped   }
    end

    describe Result::Summary do
      let(:summary)   { Result::Summary.new }
      let(:failed)    { Result::Failed.new(10, exception) }
      let(:passed)    { Result::Passed.new(11) }
      let(:skipped)   { Result::Skipped.new }
      let(:unknown)   { Result::Unknown.new }
      let(:undefined) { Result::Undefined.new }
      let(:exception) { StandardError.new }

      it "counts failed results" do
        failed.describe_to summary
        expect( summary.total_failed ).to eq 1
        expect( summary.total        ).to eq 1
      end

      it "counts passed results" do
        passed.describe_to summary
        expect( summary.total_passed ).to eq 1
        expect( summary.total        ).to eq 1
      end

      it "counts skipped results" do
        skipped.describe_to summary
        expect( summary.total_skipped ).to eq 1
        expect( summary.total         ).to eq 1
      end

      it "counts undefined results" do
        undefined.describe_to summary
        expect( summary.total_undefined ).to eq 1
        expect( summary.total           ).to eq 1
      end

      it "doesn't count unknown results" do
        unknown.describe_to summary
        expect( summary.total ).to eq 0
      end

      it "counts combinations" do
        [passed, passed, failed, skipped, undefined].each { |r| r.describe_to summary }
        expect( summary.total           ).to eq 5
        expect( summary.total_passed    ).to eq 2
        expect( summary.total_failed    ).to eq 1
        expect( summary.total_skipped   ).to eq 1
        expect( summary.total_undefined ).to eq 1
      end

      it "records durations" do
        [passed, failed].each { |r| r.describe_to summary }
        expect( summary.durations[0] ).to be_duration 11
        expect( summary.durations[1] ).to be_duration 10
      end

      it "records exceptions" do
        [passed, failed].each { |r| r.describe_to summary }
        expect( summary.exceptions ).to eq [exception]
      end
    end

    describe Result::Duration do
      subject(:duration) { Result::Duration.new(10) }

      it "exist? returns true" do
        expect( duration.exist? ).to be_truthy
      end

      it "has a duration" do
        expect( duration.duration ).to eq 10
      end
    end

    describe Result::UnknownDuration do
      subject(:duration) { Result::UnknownDuration.new }

      it "exist? returns false" do
        expect( duration.exist? ).to be_falsy
      end

      it "return duration 0" do
        expect( duration.duration ).to eq 0
      end
    end
  end
end
