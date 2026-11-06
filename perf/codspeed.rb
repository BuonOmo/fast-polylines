# frozen_string_literal: true

# Benchmark scenarios measured by CodSpeed (see codspeed.yml).
#
# Usage: ruby -I lib -I ext perf/codspeed.rb <scenario>
#
# Each scenario runs its workload many times in a single process so that the
# measured time is dominated by FastPolylines rather than by Ruby's startup.

require "fast_polylines"

# A real ~35 points route across Paris (same data as perf/benchmark.rb).
SHORT_POINTS = [
  [48.85726, 2.35238], [48.86685, 2.3209], [48.86493, 2.31891],
  [48.86464, 2.30369], [48.86272, 2.29432], [48.8538, 2.28262],
  [48.85162, 2.27885], [48.85037, 2.2733], [48.85111, 2.27228],
  [48.84901, 2.26636], [48.84795, 2.25668], [48.84939, 2.25254],
  [48.84837, 2.24899], [48.84857, 2.22729], [48.84711, 2.22407],
  [48.84238, 2.22211], [48.83941, 2.21877], [48.83961, 2.19702],
  [48.83612, 2.18306], [48.83166, 2.14879], [48.83243, 2.1392],
  [48.83964, 2.11881], [48.84222, 2.09905], [48.84196, 2.09547],
  [48.8128, 2.05831], [48.79852, 2.04373], [48.79692, 2.04008],
  [48.79496, 2.04106], [48.79544, 2.04537], [48.79446, 2.04934],
  [48.78763, 2.06262], [48.77713, 2.06017], [48.77094, 2.05524],
  [48.76883, 2.06241], [48.765, 2.06846]
].freeze

# A deterministic long route (10k points) with small, varying deltas, similar
# to a dense GPS trace.
LONG_POINTS = Array.new(10_000) do |i|
  [
    (48.8 + (Math.sin(i / 50.0) * 0.5) + (i * 1e-5)).round(6),
    (2.3 + (Math.cos(i / 70.0) * 0.5) - (i * 1e-5)).round(6)
  ]
end.freeze

SHORT_POLYLINE = FastPolylines.encode(SHORT_POINTS).freeze
LONG_POLYLINE = FastPolylines.encode(LONG_POINTS).freeze
LONG_POLYLINE_P6 = FastPolylines.encode(LONG_POINTS, 6).freeze

SCENARIOS = {
  "encode_short" => lambda {
    100_000.times { FastPolylines.encode(SHORT_POINTS) }
  },
  "decode_short" => lambda {
    100_000.times { FastPolylines.decode(SHORT_POLYLINE) }
  },
  "encode_long" => lambda {
    400.times { FastPolylines.encode(LONG_POINTS) }
  },
  "decode_long" => lambda {
    400.times { FastPolylines.decode(LONG_POLYLINE) }
  },
  "encode_long_precision_6" => lambda {
    400.times { FastPolylines.encode(LONG_POINTS, 6) }
  },
  "decode_long_precision_6" => lambda {
    400.times { FastPolylines.decode(LONG_POLYLINE_P6, 6) }
  },
  "roundtrip_long" => lambda {
    200.times { FastPolylines.decode(FastPolylines.encode(LONG_POINTS)) }
  }
}.freeze

scenario = ARGV.fetch(0) do
  abort "Usage: #{$PROGRAM_NAME} <#{SCENARIOS.keys.join('|')}>"
end
SCENARIOS.fetch(scenario) { abort "Unknown scenario: #{scenario}" }.call
