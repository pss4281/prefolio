module Rasterizer
  def self.render(url, output, width, height)
    `#{Rails.root.join('lib', 'phantomjs', 'bin', 'phantomjs')} #{ Rails.root.join('lib', 'rasterize.coffee') } '#{ url }' '#{output}' #{ width }x#{ height }`
  rescue
    puts "Exception!"
  end
end