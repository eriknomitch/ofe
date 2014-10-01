module Ofe

  # ----------------------------------------------
  # CLASS->T-SORTED-FILES ------------------------
  # ----------------------------------------------
  class TSortedFiles
    include TSort

    # --------------------------------------------
    # ATTRIBUTES ---------------------------------
    # --------------------------------------------
    attr_accessor :files, :topology

    # --------------------------------------------
    # INITIALIZE ---------------------------------
    # --------------------------------------------
    def initialize(files, topology={})
      @topology = topology

      # The topology will most likely only have a few keys/files
      # set so we need to append the rest (as empty arrays).
      #
      # This way we can sort all of them.
      files.each do |file|
        @topology[file] = [] unless @topology[file]
      end
    end

    # --------------------------------------------
    # TSORT --------------------------------------
    # --------------------------------------------
    def tsort_each(&block)
      @topology.each(&block)
    end

    def tsort_each_node(&block)
      @topology.each_key(&block)
    end
    
    def tsort_each_child(node, &block)
      @topology[node].each(&block)
    end

    def sorted
      tsort
    end
  
  end
end
