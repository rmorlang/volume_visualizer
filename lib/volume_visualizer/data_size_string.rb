module VolumeVisualizer
  class DataSizeString < String
    ABBREV_MAP = {
      "B" => 1024**0,
      "K" => 1024**1,
      "M" => 1024**2,
      "G" => 1024**3,
      "T" => 1024**4,
      "P" => 1024**5,
      "E" => 1024**6,
      "Z" => 1024**7
    }

    def last_char
      to_s[-1].chr
    end

    def multiplier
      ABBREV_MAP[last_char] || 1
    end

    def bytes
      (to_f * multiplier).to_i
    end
  end
end
