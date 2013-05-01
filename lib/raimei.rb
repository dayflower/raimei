require 'raimei/version'
require 'raimei/navigation'
require 'raimei/pager'

# Rai-mei (雷鳴) is the very tiny pagination library.
#
# It DOES ...
# * Manage pager's page numbers (via {Raimei::Navigation} and {Raimei::Pager})
# * Calculate record offset for specified page (via {Raimei::Pager})
#
# It DOES NOT ...
# * Render pager
# * Retrieve records from any storage
#
# This library is independent of ActiveRecord and other ORMs,
# and also does not rely on Rails and other frameworks.
#
module Raimei
end
