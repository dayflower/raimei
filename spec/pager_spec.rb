require 'spec_helper'

describe Raimei::Pager do
  context 'total_entries = 123, entries_per_page = 10, pages_on_navigation = 5' do
    before :all do
      @pager = Raimei::Pager.new(:total_entries       => 123,
                                 :entries_per_page    => 10,
                                 :pages_on_navigation => 5    )
    end

    describe '#total_pages' do
      example { expect(@pager.total_pages).to eq 13 }
    end

    context 'current = 1' do
      before :all do
        @pager.current = 1
      end

      describe '#offset' do
        example { expect(@pager.offset).to eq 0 }
      end

      describe '#offset_for_page' do
        context 'page 5' do
          example { expect(@pager.offset_for_page(5)).to eq 40 }
        end

        context 'page 0' do
          example { expect { @pager.offset_for_page(0) }.to raise_error }
        end

        context 'page 20' do
          example { expect { @pager.offset_for_page(20) }.to raise_error }
        end
      end

      describe '#top_entry_index_for_current' do
        example { expect(@pager.top_entry_index_for_current).to eq 1 }
      end

      describe '#bottom_entry_index_for_current' do
        example { expect(@pager.bottom_entry_index_for_current).to eq 10 }
      end
    end

    context 'offset = 30' do
      before :all do
        @pager.offset = 30
      end

      describe '#current' do
        example { expect(@pager.current).to eq 4 }
      end

      describe '#top_entry_index_for_current' do
        example { expect(@pager.top_entry_index_for_current).to eq 31 }
      end

      describe '#bottom_entry_index_for_current' do
        example { expect(@pager.bottom_entry_index_for_current).to eq 40 }
      end

      describe '#first' do
        example { expect(@pager.first).to eq 2 }
      end

      describe '#last' do
        example { expect(@pager.last).to eq 6 }
      end

      describe '#backward' do
        example { expect(@pager.backward).to be_nil }
      end

      describe '#forward' do
        example { expect(@pager.forward).to eq 9 }
      end
    end

    # TODO offset not aligned

    context 'invalid current' do
      context 'current = 0' do
        example { expect { @pager.current = 0 }.to raise_error }
      end

      context 'current = -1' do
        example { expect { @pager.current = -1 }.to raise_error }
      end

      context 'current = 20' do
        # TODO proper spec?
        example { expect { @pager.current = 20 }.to raise_error }
      end
    end
  end

  describe 'enumeration' do
    before :all do
      @pager = Raimei::Pager.new(:total_entries       => 123,
                                 :entries_per_page    => 10,
                                 :pages_on_navigation => 5,
                                 :offset              => 30   )
    end

    describe '#as_numeric' do
      before :all do
        @enum = @pager.as_numeric.each
      end

      example { expect(@enum.next).to eq [ 2, 10 ] }
      example { expect(@enum.next).to eq [ 3, 20 ] }
      example { expect(@enum.next).to eq [ 4, 30 ] }
      example { expect(@enum.next).to eq [ 5, 40 ] }
      example { expect(@enum.next).to eq [ 6, 50 ] }
      example { expect { @enum.next }.to raise_error StopIteration }
    end

    describe '#each' do
      before :all do
        @enum = @pager.each
      end

      context '1st' do
        before :all do
          @page = @enum.next
        end

        subject { @page }

        its(:page)     { should eq 2     }
        its(:current?) { should be_false }
        its(:offset)   { should eq 10    }

        its(:page_size) { should eq 10 }
      end

      context '2nd' do
        before :all do
          @page = @enum.next
        end

        subject { @page }

        its(:page)     { should eq 3     }
        its(:current?) { should be_false }
        its(:offset)   { should eq 20    }
      end

      context '3rd' do
        before :all do
          @page = @enum.next
        end

        subject { @page }

        its(:page)     { should eq 4     }
        its(:current?) { should be_true  }
        its(:offset)   { should eq 30    }
      end

      context '4th' do
        before :all do
          @page = @enum.next
        end

        subject { @page }

        its(:page)     { should eq 5     }
        its(:current?) { should be_false }
        its(:offset)   { should eq 40    }
      end

      context '5th' do
        before :all do
          @page = @enum.next
        end

        subject { @page }

        its(:page)     { should eq 6     }
        its(:current?) { should be_false }
        its(:offset)   { should eq 50    }
      end

      context '6th' do
        example { expect { @enum.next }.to raise_error StopIteration }
      end
    end
  end

  # TODO total_entries = 0
end
