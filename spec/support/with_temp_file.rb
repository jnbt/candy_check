require 'tempfile'

module WithTempFile
  def self.included(target)
    target.instance_eval do
      def self.with_temp_file(name)
        random_name = "#{name}-#{rand(100_000..200_000)}"
        full_path   = File.join(Dir.tmpdir, random_name)
        define_method "#{name}_path" do
          full_path
        end
        define_method "unlink_#{name}" do
          return unless File.exist?(full_path)
          File.unlink(full_path)
        end

        after do
          send("unlink_#{name}")
        end
      end
    end
  end
end
