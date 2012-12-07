guard 'rspec', cli: '--format Fuubar --color', all_after_pass: false do
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb})     { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^spec/spec_helper.rb})   { |m| "spec/" }
end
