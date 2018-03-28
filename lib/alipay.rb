Alipay::API_URL = 'https://openapi.alipay.com/gateway.do'
Alipay::APP_ID = ENV['ALIPAY_APP_ID']
# Alipay::APP_PRIVATE_KEY = ENV['ALIPAY_APP_PRIVATE_KEY']
# Alipay::ALIPAY_PUBLIC_KEY = ENV['ALIPAY_PUBLIC_KEY']
Alipay::NOTIFY_URL = ENV['ALIPAY_NOTIFY_URL']

Alipay::APP_PRIVATE_KEY = <<-EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAwTPEJxoDZvF3OTvLh8sC1DtckpT86E1yD4sm4i+Rf5qNZr7s
LBUStbKhJ3ghrZzNFGdabHqAA1w2mBgyQcKeddLZUfWKt884mmWZXRoK7EXjZOHt
XZ7hNsUImHAyAo+dVN5UiP3cmBtuV6YZtwmWLguzGf3SdBYnl37UCLATiZquZGWf
mfX6cJqHnW2B4gnn90hJnC6XjFqp9ltrvZT696VPy0k/VgMQalEPV1WfLx3Ia09k
rVpfXy4OMgtgoOIddV1qtXdNYdL05hBFj/n/dcyo6VHu4LkAPRrEWkPriG7WvjAf
bhEjI2RDQphfYBkjGTL+o5u3OrYPCEHxdKA2BQIDAQABAoIBAAcQOW+kh9NPqKgz
A3Hnfib8NJo3UDe9/RmMYNOMIamkoN7MxB2od5KlATdMMQ8D2IuSa7/jiqKU0Hon
CE9XKivslX1lmLi3nr4mUMESnqucsn+RsvflQx6ZfYL1Nx7Y2UutBTIs9c+p0RLr
Q61pcFAmpVmh6fvMg44KWP4oUc6KBOq1hnIBcz2EG412ZYQMTrmzy1b33fUn1LgX
Ivk+Ao07CoAI6WoD1LLth2rjG/saJ6UtAqeQgcJf1CRKUwZmQLaEpNNDdkIltjt1
PsDMwErSkahWz8Bx4e72g/0WD0xOFZ8Yyt09yq9c64nb7a9qxM0FE1XnBlLe6551
LBilh9ECgYEA4eUcNPNg52fqhaEM8RUenMiAkGUqUz3kKZ6SvPtesOKHoGuJKzdl
MHYVNwbhKz9Edg5SuHVUeTc2bH95MiwezAuA4cXfBZKR/z7mNP1uSNFcFCdcWpRN
S+00OZVuPt1NGZkKzyrg5xJuRw/ZjDf80rvaHT+3YLkcHlyGjKnMsHcCgYEA2vNF
3818JzswG3X40lsKn5bKmpNqT7yJGw//6h+z9fhPt5fMvsIreYQFvqCIO7bHgXJJ
MRKA176plG+i7CKR1j76hYbbN2Wxv0A4yWi3MH2rghHUO+kYHICS40dkzi3DFQ8X
bYjH9ke1JBMtIyV/cUufyZDxIpdDxVu6RB39yGMCgYBQyzEbfzDZk0E+KiwGzhb0
3IGfI4/P1gMVH7I8BWwIt/zqU4vr+RQoERPlaoB+h1JlJxpO/ygHcsf0ZmNinoUl
VbfzCGKMC7BMKqMLsNkRElBspOdTPlenIF/deKTFt0EsNqC3GA74lo76u6CDlkLG
3IlWjMN5xLtZ4J3/EXw0YQKBgCfd1eI7SxjlmQvW/jhnJVcLoNZmcxwTqy9HSYS6
wwzNas52EGzHdB0LIfSkzEl7LXZvdc4+nUErUTta3GJ8pOtKyljXxkCe/q9hJTXf
IEPvDfSABJHoDmDaNGS30i4MfRHvjod+OVKpmdz4tOZKZJsfdve/sXhn7IoZ+p9+
ioAbAoGBAKecxiWx5Zsl97QjW/x09rAsGmlgCv3DHzTkbKiSbKCySFic78tIBGsz
lXDgh/H4IJIAgcQeDhbWl7lDpLfNu6cQxjDedFZNM48rayeqzBP5+fnoRsBLJguf
p0b0nFOF5drEbEsqjw74Xqb4WPDC9Ac7P5zDZcW7+cgTsDWSgaGn
-----END RSA PRIVATE KEY-----
EOF
Alipay::ALIPAY_PUBLIC_KEY = <<-EOF
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArnBji2YViEWfFG9KMqBm
6OxVMpn2gSOZ9zbmdUXBgFJjJpkzDJ9R+MHacF4ycAVHKTWgca0fJs1vZ7tvJG2Q
FWnYZYSzfq5+GbOdrCWg4Dk1kilg75tFO/Mf7nlY/WRcJEgc1I+L8pF5MKt0RklF
XdEaMb1HncR/6vW/Rfv8wbuCmrzkoyb8NoOdA4eu8EfBxY5JJ5VIuafZu94P6sxG
042croP02Qkr38ecoKIvnPSGzK2ug29vx1bQPu/nRsKQ22qr/XmOQodHXfNQImji
misN1BctVyeoUYkUg8HkU6ilaLI22/uzf8JrdRzwfVBi1ySwu40A7ZsMnDRRT0TC
swIDAQAB
-----END PUBLIC KEY-----
EOF

Alipay::INIT_CLIENT = Alipay::Client.new(
  url: Alipay::API_URL,
  app_id: Alipay::APP_ID,
  app_private_key: Alipay::APP_PRIVATE_KEY,
  alipay_public_key: Alipay::ALIPAY_PUBLIC_KEY,
  format: 'json',
  charset: 'UTF-8',
  sign_type: 'RSA2'
)