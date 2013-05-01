require 'spec_helper'

describe Raimei::Sorter do
  describe '#compact_array' do
    before :all do
      s = Raimei::Sorter.new([])

      class << s
        public :compact_array
      end

      @c = lambda { |a, b|
        a = a.map { |i| [ i.upcase, i ] }
        b = b.map { |i| [ i.upcase, i ] }
        r = s.compact_array(a, b)
        r.map { |i| i[1] }
      }
    end

    it { expect(@c.call(%w[A B C D E], %w[A B C D E])).to eq %w[]          }
    it { expect(@c.call(%w[D A B C E], %w[A B C D E])).to eq %w[D]         }
    it { expect(@c.call(%w[D B A C E], %w[A B C D E])).to eq %w[D B]       }
    it { expect(@c.call(%w[D B E A C], %w[A B C D E])).to eq %w[D B E]     }
    it { expect(@c.call(%w[A D B C E], %w[A B C D E])).to eq %w[A D]       }
    it { expect(@c.call(%w[A B C E D], %w[A B C D E])).to eq %w[A B C E]   }
    it { expect(@c.call(%w[c A B D E], %w[A B C D E])).to eq %w[c]         }
    it { expect(@c.call(%w[A b C d E], %w[A B C D E])).to eq %w[A b C d]   }
    it { expect(@c.call(%w[d A b C E], %w[A B C D E])).to eq %w[d A b]     }

    it { expect(@c.call(%w[A B M C D H I E F G J K L N],
                        %w[A B C D E F G H I J K L M N])).to \
                     eq %w[A B M C D H I              ] }
  end

  context 'multiple sort fields' do
    before :all do
      @default_order = [
        [ :xyz, :asc  ],
        [ :foo, :desc ],
        [ :abc, :desc ],
        [ :def, :asc  ],
        [ :bar, :asc  ],
      ]

      @template = Raimei::Sorter.new(@default_order)
    end

    context 'initial state' do
      describe '#order' do
        it do
          expect(@template.order).to eq @default_order
        end
      end
    end

    context 'sort with foo,def-,xyz' do
      before :all do
        @sorter = @template.sort('foo,def-,xyz')
      end

      describe '#order' do
        it do
          renewed_order = [
            [ :foo, :asc  ],
            [ :def, :desc ],
            [ :xyz, :asc  ],
            [ :abc, :desc ],
            [ :bar, :asc  ],
          ]

          expect(@sorter.order).to eq renewed_order
        end
      end

      describe 'state retrieval methods' do
        describe '#top_asc?' do
          context 'with :foo' do
            it { expect(@sorter.top_asc?(:foo)).to be_true }
          end
          context 'with :def' do
            it { expect(@sorter.top_asc?(:def)).to be_false }
          end
          context 'with :xyz' do
            it { expect(@sorter.top_asc?(:xyz)).to be_false }
          end
          context 'with :abc' do
            it { expect(@sorter.top_asc?(:abc)).to be_false }
          end
          context 'with :bar' do
            it { expect(@sorter.top_asc?(:bar)).to be_false }
          end
        end

        describe '#top_desc?' do
          context 'with :foo' do
            it { expect(@sorter.top_desc?(:foo)).to be_false }
          end
          context 'with :def' do
            it { expect(@sorter.top_desc?(:def)).to be_false }
          end
          context 'with :xyz' do
            it { expect(@sorter.top_desc?(:xyz)).to be_false }
          end
          context 'with :abc' do
            it { expect(@sorter.top_desc?(:abc)).to be_false }
          end
          context 'with :bar' do
            it { expect(@sorter.top_desc?(:bar)).to be_false }
          end
        end

        describe '#asc?' do
          context 'with :foo' do
            it { expect(@sorter.asc?(:foo)).to be_true }
          end
          context 'with :def' do
            it { expect(@sorter.asc?(:def)).to be_false }
          end
          context 'with :xyz' do
            it { expect(@sorter.asc?(:xyz)).to be_true }
          end
          context 'with :abc' do
            it { expect(@sorter.asc?(:abc)).to be_false }
          end
          context 'with :bar' do
            it { expect(@sorter.asc?(:bar)).to be_true }
          end
        end

        describe '#desc?' do
          context 'with :foo' do
            it { expect(@sorter.desc?(:foo)).to be_false }
          end
          context 'with :def' do
            it { expect(@sorter.desc?(:def)).to be_true }
          end
          context 'with :xyz' do
            it { expect(@sorter.desc?(:xyz)).to be_false }
          end
          context 'with :abc' do
            it { expect(@sorter.desc?(:abc)).to be_true }
          end
          context 'with :bar' do
            it { expect(@sorter.desc?(:bar)).to be_false }
          end
        end
      end

      describe '#link_for without direction' do
        context 'with foo' do
          # top sorter, so inverted
          it { expect(@sorter.link_for(:foo)).to eq 'foo-,def-' }
        end

        context 'with bar' do
          it { expect(@sorter.link_for(:bar)).to eq 'bar,foo,def-' }
        end

        context 'with abc' do
          # :abc is default :desc, so which is prefer?
          # think simply.  direction of non-top sorter keeps unchanged.
          it { expect(@sorter.link_for(:abc)).to eq 'abc-,foo,def-' }
        end

        context 'with def' do
          it { expect(@sorter.link_for(:def)).to eq 'def-,foo' }
        end

        context 'with xyz' do
          it { expect(@sorter.link_for(:xyz)).to eq 'xyz,foo,def-' }
        end
      end

      describe '#link_for with direction' do
        context 'with foo+' do
          it { expect(@sorter.link_for('foo+')).to eq 'foo,def-' }
        end

        context 'with bar-' do
          it { expect(@sorter.link_for('bar-')).to eq 'bar-,foo,def-' }
        end

        context 'with abc+' do
          it { expect(@sorter.link_for('abc+')).to eq 'abc,foo,def-' }
        end

        context 'with def-' do
          it { expect(@sorter.link_for('def-')).to eq 'def-,foo' }
        end

        context 'with xyz-' do
          it { expect(@sorter.link_for('xyz-')).to eq 'xyz-,foo,def-' }
        end
      end
    end
  end

  context 'single sort field' do
    before :all do
      @default_order = [
        [ :xyz, :asc  ],
        [ :foo, :desc ],
        [ :abc, :desc ],
        [ :def, :asc  ],
        [ :bar, :asc  ],
      ]

      @template = Raimei::Sorter.new(@default_order, :single => true)
    end

    context 'initial state' do
      describe '#order' do
        it do
          expect(@template.order).to eq @default_order
        end
      end
    end

    context 'sort with foo,def-,xyz' do
      before :all do
        # 2nd and 3rd fields are ignored
        @sorter = @template.sort('foo,def-,xyz')
      end

      describe '#order' do
        it do
          renewed_order = [
            [ :foo, :asc  ],
            [ :xyz, :asc  ],
            [ :abc, :desc ],
            [ :def, :asc  ],
            [ :bar, :asc  ],
          ]

          expect(@sorter.order).to eq renewed_order
        end
      end

      describe '#link_for without direction' do
        context 'with foo' do
          # top sorter, so inverted
          it { expect(@sorter.link_for(:foo)).to eq 'foo-' }
        end

        context 'with bar' do
          it { expect(@sorter.link_for(:bar)).to eq 'bar' }
        end

        context 'with abc' do
          it { expect(@sorter.link_for(:abc)).to eq 'abc-' }
        end

        context 'with def' do
          it { expect(@sorter.link_for(:def)).to eq 'def' }
        end

        context 'with xyz' do
          it { expect(@sorter.link_for(:xyz)).to eq 'xyz' }
        end
      end

      describe '#link_for with direction' do
        context 'with foo+' do
          it { expect(@sorter.link_for('foo+')).to eq 'foo' }
        end

        context 'with bar-' do
          it { expect(@sorter.link_for('bar-')).to eq 'bar-' }
        end

        context 'with abc+' do
          it { expect(@sorter.link_for('abc+')).to eq 'abc' }
        end

        context 'with def-' do
          it { expect(@sorter.link_for('def-')).to eq 'def-' }
        end

        context 'with xyz-' do
          it { expect(@sorter.link_for('xyz-')).to eq 'xyz-' }
        end
      end
    end
  end
end

