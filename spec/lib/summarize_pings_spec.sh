# spec/lib/summarize_pings_spec.sh
Describe 'lib/summarize_pings.sh'
  Include lib/summarize_pings.sh

  Describe 'summarize_pings()'
    It 'calculates stats correctly from sample input'
      # We provide the "Text" (raw data) to interpret
      Data
        #|64 bytes from 8.8.8.8: icmp_seq=1 ttl=116 time=10.0 ms
        #|64 bytes from 8.8.8.8: icmp_seq=2 ttl=116 time=20.0 ms
        #|64 bytes from 8.8.8.8: icmp_seq=3 ttl=116 time=30.0 ms
      End

      When call summarize_pings
      The output should include "Min: 10.000"
      The output should include "Avg: 20.000"
      The output should include "Max: 30.000"
      The output should include "0.00% packet loss"
    End

    It 'detects packet loss'
      Data
        #|Request timeout for icmp_seq 1
        #|64 bytes from 8.8.8.8: icmp_seq=2 ttl=116 time=10.0 ms
      End

      When call summarize_pings
      The output should include "50.00% packet loss"
    End
  End
End