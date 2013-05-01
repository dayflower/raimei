require 'spec_helper'

describe Raimei::Navigation do
  context '5 pages navigation for 20 pages' do
    before do
      @nav = Raimei::Navigation.new(:pages_on_navigation => 5,
                                    :total_pages         => 20)
    end

    subject { @nav }

    its(:leading) { should eq 1  }
    its(:trailing) { should eq 20 }

    context 'current page is 1' do
      # [1] 2 3 4 5 >> >>>

      before do
        @nav.current = 1
      end

      describe '#current?' do
        context 'for 1' do
          example { expect(@nav.current?(1)).to be_true }
        end

        context 'for 5' do
          example { expect(@nav.current?(5)).to be_false }
        end
      end

      its(:first)     { should eq 1 }
      its(:last)      { should eq 5 }
      its(:leading?)  { should be_false }
      its(:trailing?) { should be_true }
      its(:prev)      { should be_nil }
      its(:next)      { should eq 2 }
      its(:backward)  { should be_nil }
      its(:forward)   { should eq 6 }
    end

    context 'current page is 2' do
      # 1 [2] 3 4 5 >> >>>

      before do
        @nav.current = 2
      end

      its(:first)     { should eq 1 }
      its(:last)      { should eq 5 }
      its(:leading?)  { should be_false }
      its(:trailing?) { should be_true }
      its(:backward)  { should be_nil }
      its(:forward)   { should eq 7 }
    end

    context 'current page is 3' do
      # 1 2 [3] 4 5 >> >>>

      before do
        @nav.current = 3
      end

      its(:first)     { should eq 1 }
      its(:last)      { should eq 5 }
      its(:leading?)  { should be_false }
      its(:trailing?) { should be_true }
      its(:prev)      { should eq 2 }
      its(:next)      { should eq 4 }
      its(:backward)  { should be_nil }
      its(:forward)   { should eq 8 }
    end

    context 'current page is 4' do
      # <<< 2 3 [4] 5 6 >> >>>

      before do
        @nav.current = 4
      end

      its(:first)     { should eq 2 }
      its(:last)      { should eq 6 }
      its(:leading?)  { should be_true }
      its(:trailing?) { should be_true }
      its(:prev)      { should eq 3 }
      its(:next)      { should eq 5 }
      # TODO proper spec? (or 1 is better?)
      its(:backward)  { should be_nil }
      its(:forward)   { should eq 9 }
    end

    context 'current page is 5' do
      # <<< 3 4 [5] 6 7 >> >>>

      before do
        @nav.current = 5
      end

      its(:first)     { should eq 3 }
      its(:last)      { should eq 7 }
      its(:leading?)  { should be_true }
      its(:trailing?) { should be_true }
      # TODO proper spec? (or 1 is better?)
      its(:backward)  { should be_nil }
      its(:forward)   { should eq 10 }
    end

    context 'current page is 8' do
      # <<< << 6 7 [8] 9 10 >> >>>

      before do
        @nav.current = 8
      end

      its(:first)     { should eq 6 }
      its(:last)      { should eq 10 }
      its(:leading?)  { should be_true }
      its(:trailing?) { should be_true }
      its(:prev)      { should eq 7 }
      its(:next)      { should eq 9 }
      its(:backward)  { should eq 3 }
      its(:forward)   { should eq 13 }
    end

    context 'current page is 15' do
      # <<< << 13 14 [15] 16 17 >> >>>

      before do
        @nav.current = 15
      end

      its(:first)     { should eq 13 }
      its(:last)      { should eq 17 }
      its(:leading?)  { should be_true }
      its(:trailing?) { should be_true }
      its(:backward)  { should eq 10 }
      its(:forward)   { should eq 20 }
    end

    context 'current page is 17' do
      # <<< << 15 16 [17] 18 19 >>>

      before do
        @nav.current = 17
      end

      its(:first)     { should eq 15 }
      its(:last)      { should eq 19 }
      its(:leading?)  { should be_true }
      its(:trailing?) { should be_true }
      its(:backward)  { should eq 12 }
      # TODO proper spec? (or 20 is better?)
      its(:forward)   { should be_nil }
    end

    context 'current page is 18' do
      # <<< << 16 17 [18] 19 20

      before do
        @nav.current = 18
      end

      its(:first)     { should eq 16 }
      its(:last)      { should eq 20 }
      its(:leading?)  { should be_true }
      its(:trailing?) { should be_false }
      its(:backward)  { should eq 13 }
      its(:forward)   { should be_nil }
    end

    context 'current page is 20' do
      # <<< << 16 17 18 19 [20]

      before do
        @nav.current = 20
      end

      its(:first)     { should eq 16 }
      its(:last)      { should eq 20 }
      its(:leading?)  { should be_true }
      its(:trailing?) { should be_false }
      its(:backward)  { should eq 15 }
      its(:forward)   { should be_nil }
    end
  end

  context '5 pages navigation for 8 pages' do
    before do
      @nav = Raimei::Navigation.new(:pages_on_navigation => 5,
                                    :total_pages         => 8)
    end

    subject { @nav }

    its(:leading)  { expect(@nav.leading).to  eq 1 }
    its(:trailing) { expect(@nav.trailing).to eq 8 }

    context 'current page is 1' do
      # [1] 2 3 4 5 >> >>>

      before do
        @nav.current = 1
      end

      describe '#current?' do
        context 'for 1' do
          example { expect(@nav.current?(1)).to be_true }
        end

        context 'for 3' do
          example { expect(@nav.current?(3)).to be_false }
        end
      end

      its(:first)     { should eq 1 }
      its(:last)      { should eq 5 }
      its(:leading?)  { should be_false }
      its(:trailing?) { should be_true }
      its(:prev)      { should be_nil }
      its(:next)      { should eq 2 }
      its(:backward)  { should be_nil }
      its(:forward)   { should eq 6 }
    end

    context 'current page is 4' do
      # <<< 2 3 [4] 5 6 >>>

      before do
        @nav.current = 4
      end

      its(:first)     { should eq 2 }
      its(:last)      { should eq 6 }
      its(:leading?)  { should be_true }
      its(:trailing?) { should be_true }
      # TODO proper spec? (or 1 is better?)
      its(:backward)  { should be_nil }
      # TODO proper spec? (or 8 is better?)
      its(:forward)   { should be_nil }
    end

    context 'current page is 7' do
      # <<< << 4 5 6 [7] 8

      before do
        @nav.current = 7
      end

      its(:first)     { should eq 4 }
      its(:last)      { should eq 8 }
      its(:leading?)  { should be_true }
      its(:trailing?) { should be_false }
      its(:backward)  { should eq 2 }
      its(:forward)   { should be_nil }
    end

    context 'current page is 8' do
      # <<< << 4 5 6 7 [8]

      before do
        @nav.current = 8
      end

      its(:first)     { should eq 4 }
      its(:last)      { should eq 8 }
      its(:leading?)  { should be_true }
      its(:trailing?) { should be_false }
      its(:backward)  { should eq 3 }
      its(:forward)   { should be_nil }
    end
  end

  context '5 pages navigation for 7 pages' do
    before do
      @nav = Raimei::Navigation.new(:pages_on_navigation => 5,
                                    :total_pages         => 7)
    end

    subject { @nav }

    its(:leading)  { expect(@nav.leading).to  eq 1 }
    its(:trailing) { expect(@nav.trailing).to eq 7 }

    context 'current page is 1' do
      # [1] 2 3 4 5 >> >>>

      before do
        @nav.current = 1
      end

      its(:first)     { should eq 1 }
      its(:last)      { should eq 5 }
      its(:leading?)  { should be_false }
      its(:trailing?) { should be_true }
      its(:prev)      { should be_nil }
      its(:next)      { should eq 2 }
      its(:backward)  { should be_nil }
      its(:forward)   { should eq 6 }
    end

    context 'current page is 3' do
      # 1 2 [3] 4 5 >>>

      before do
        @nav.current = 3
      end

      its(:first)     { should eq 1 }
      its(:last)      { should eq 5 }
      its(:leading?)  { should be_false }
      its(:trailing?) { should be_true }
      its(:prev)      { should eq 2 }
      its(:next)      { should eq 4 }
      its(:backward)  { should be_nil }
      # TODO proper spec? (or 7 is better?)
      its(:forward)   { should be_nil }
    end

    context 'current page is 6' do
      # <<< << 3 4 5 [6] 7

      before do
        @nav.current = 6
      end

      its(:first)     { should eq 3 }
      its(:last)      { should eq 7 }
      its(:leading?)  { should be_true }
      its(:trailing?) { should be_false }
      its(:prev)      { should eq 5 }
      its(:next)      { should eq 7 }
      its(:backward)  { should eq 1 }
      its(:forward)   { should be_nil }
    end
  end

  context '5 pages navigation for 3 pages' do
    before do
      @nav = Raimei::Navigation.new(:pages_on_navigation => 5,
                                    :total_pages         => 3)
    end

    subject { @nav }

    its(:leading)  { expect(@nav.leading).to  eq 1 }
    its(:trailing) { expect(@nav.trailing).to eq 3 }

    context 'current page is 1' do
      # [1] 2 3

      before do
        @nav.current = 1
      end

      its(:first)     { should eq 1 }
      its(:last)      { should eq 3 }
      its(:leading?)  { should be_false }
      its(:trailing?) { should be_false }
      its(:prev)      { should be_nil }
      its(:next)      { should eq 2 }
      its(:backward)  { should be_nil }
      its(:forward)   { should be_nil }
    end

    context 'current page is 2' do
      # 1 [2] 3

      before do
        @nav.current = 2
      end

      its(:first)     { should eq 1 }
      its(:last)      { should eq 3 }
      its(:leading?)  { should be_false }
      its(:trailing?) { should be_false }
      its(:prev)      { should eq 1 }
      its(:next)      { should eq 3 }
      its(:backward)  { should be_nil }
      its(:forward)   { should be_nil }
    end

    context 'current page is 3' do
      # 1 2 [3]

      before do
        @nav.current = 3
      end

      its(:first)     { should eq 1 }
      its(:last)      { should eq 3 }
      its(:leading?)  { should be_false }
      its(:trailing?) { should be_false }
      its(:prev)      { should eq 2 }
      its(:next)      { should be_nil }
      its(:backward)  { should be_nil }
      its(:forward)   { should be_nil }
    end
  end

  context '5 pages navigation for 1 page' do
    before do
      @nav = Raimei::Navigation.new(:pages_on_navigation => 5,
                                    :total_pages         => 1)
    end

    subject { @nav }

    its(:leading)  { expect(@nav.leading).to  eq 1 }
    its(:trailing) { expect(@nav.trailing).to eq 1 }

    context 'current page is 1' do
      # [1]

      before do
        @nav.current = 1
      end

      its(:first)     { should eq 1 }
      its(:last)      { should eq 1 }
      its(:leading?)  { should be_false }
      its(:trailing?) { should be_false }
      its(:prev)      { should be_nil }
      its(:next)      { should be_nil }
      its(:backward)  { should be_nil }
      its(:forward)   { should be_nil }
    end
  end

  context '5 pages navigation for no page' do
    before do
      @nav = Raimei::Navigation.new(:pages_on_navigation => 5,
                                    :total_pages         => 0)
    end

    subject { @nav }

    its(:leading)  { expect(@nav.leading).to  be_nil }
    its(:trailing) { expect(@nav.trailing).to be_nil }

    context 'current page is 1' do
      # [1]

      before do
        @nav.current = 1
      end

      its(:first)     { should be_nil }
      its(:last)      { should be_nil }
      its(:leading?)  { should be_false }
      its(:trailing?) { should be_false }
      its(:prev)      { should be_nil }
      its(:next)      { should be_nil }
      its(:backward)  { should be_nil }
      its(:forward)   { should be_nil }
    end
  end

  context 'unlimited pages navigation for 3 pages' do
    before do
      @nav = Raimei::Navigation.new(:pages_on_navigation => 0,
                                    :total_pages         => 3)
    end

    subject { @nav }

    its(:leading)  { expect(@nav.leading).to  eq 1 }
    its(:trailing) { expect(@nav.trailing).to eq 3 }

    context 'current page is 1' do
      # [1] 2 3

      before do
        @nav.current = 1
      end

      its(:first)     { should eq 1 }
      its(:last)      { should eq 3 }
      its(:leading?)  { should be_false }
      its(:trailing?) { should be_false }
      its(:prev)      { should be_nil }
      its(:next)      { should eq 2 }
      its(:backward)  { should be_nil }
      its(:forward)   { should be_nil }
    end

    context 'current page is 2' do
      # 1 [2] 3

      before do
        @nav.current = 2
      end

      its(:first)     { should eq 1 }
      its(:last)      { should eq 3 }
      its(:leading?)  { should be_false }
      its(:trailing?) { should be_false }
      its(:prev)      { should eq 1 }
      its(:next)      { should eq 3 }
      its(:backward)  { should be_nil }
      its(:forward)   { should be_nil }
    end

    context 'current page is 3' do
      # 1 2 [3]

      before do
        @nav.current = 3
      end

      its(:first)     { should eq 1 }
      its(:last)      { should eq 3 }
      its(:leading?)  { should be_false }
      its(:trailing?) { should be_false }
      its(:prev)      { should eq 2 }
      its(:next)      { should be_nil }
      its(:backward)  { should be_nil }
      its(:forward)   { should be_nil }
    end
  end

  describe 'enumeration' do
    before :all do
      @nav = Raimei::Navigation.new(:pages_on_navigation => 5,
                                    :total_pages         => 20,
                                    :current_page        => 4  )
      # <<< 2 3 [4] 5 6 >> >>>
    end

    describe '#as_numeric' do
      before :all do
        @enum = @nav.as_numeric.each
      end

      example { expect(@enum.next).to eq 2 }
      example { expect(@enum.next).to eq 3 }
      example { expect(@enum.next).to eq 4 }
      example { expect(@enum.next).to eq 5 }
      example { expect(@enum.next).to eq 6 }
      example { expect { @enum.next }.to raise_error StopIteration }
    end

    describe '#each' do
      before :all do
        @enum = @nav.each
      end

      context '1st' do
        before :all do
          @page = @enum.next
        end

        subject { @page }

        its(:page)     { should eq 2     }
        its(:current?) { should be_false }
      end

      context '2nd' do
        before :all do
          @page = @enum.next
        end

        subject { @page }

        its(:page)     { should eq 3     }
        its(:current?) { should be_false }
      end

      context '3rd' do
        before :all do
          @page = @enum.next
        end

        subject { @page }

        its(:page)     { should eq 4     }
        its(:current?) { should be_true  }
      end

      context '4th' do
        before :all do
          @page = @enum.next
        end

        subject { @page }

        its(:page)     { should eq 5     }
        its(:current?) { should be_false }
      end

      context '5th' do
        before :all do
          @page = @enum.next
        end

        subject { @page }

        its(:page)     { should eq 6     }
        its(:current?) { should be_false }
      end

      context '6th' do
        example { expect { @enum.next }.to raise_error StopIteration }
      end
    end
  end

  # TODO context: pages_per_navigation = 0, current = 0

  # TODO illegal edge cases
end
