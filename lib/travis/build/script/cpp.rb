module Travis
  module Build
    class Script
      class Cpp < Script
        DEFAULTS = {
          compiler: 'g++'
        }

        def export
          super
          sh.export 'TRAVIS_COMPILER', compiler
          sh.export 'CXX', cxx
          sh.export 'CC', cc # some projects also need to compile some C, e.g. Rubinius. MK.
        end

        def announce
          super
          sh.cmd "#{compiler} --version"
        end

        def script
          sh.cmd './configure && make && make test'
        end

        def cache_slug
          super << '--compiler-' << compiler.tr('+', 'p')
        end

        def install
          super
          if data.cache?(:ccache)
            directory_cache.add('~/.ccache')
          end
        end

        def use_directory_cache?
          super || data.cache?(:ccache)
        end

        private

          def compiler
            config[:compiler].to_s
          end

          def cxx
            case compiler
            when /^gcc/i, /^g\+\+/i then
              'g++'
            when /^clang/i, /^clang\+\+/i then
              'clang++'
            else
              'g++'
            end
          end

          def cc
            case compiler
            when /^gcc/i, /^g\+\+/i then
              'gcc'
            when /^clang/i, /^clang\+\+/i then
              'clang'
            else
              'gcc'
            end
          end
      end
    end
  end
end
