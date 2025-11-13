# To run these tests, you need the Pester module.
# You can install it with: Install-Module -Name Pester -Force
# Then run the tests with: Invoke-Pester -Path 'c:\Users\ASLS\Software\Code\0p3nt3ch53C\Init\win\init.Tests.ps1'

# Import the functions from your script
. "$PSScriptRoot\init.ps1"

Describe 'CheckAPIStatusCode' {
    Context 'when given a successful response' {
        It 'should return the response object' {
            # Mock a response object with a 200 status code
            $mockResponse = [pscustomobject]@{
                StatusCode = 200
                Content    = 'Success'
            }

            $result = CheckAPIStatusCode -response $mockResponse
            $result | Should -Be $mockResponse
        }
    }

    Context 'when given an unsuccessful response' {
        It 'should return $null for a non-200 status code' {
            # Mock a response object with a 404 status code
            $mockResponse = [pscustomobject]@{ StatusCode = 404 }
            $result = CheckAPIStatusCode -response $mockResponse
            $result | Should -BeNull
        }
    }
}

Describe 'APICall' {
    # Mock the functions that APICall depends on before each test
    BeforeEach {
        # Mock Invoke-WebRequest to avoid real network calls
        Mock -CommandName 'Invoke-WebRequest' -MockWith {
            # This default mock will throw if Invoke-WebRequest is called with unexpected parameters
        } | Out-Null

        # Mock CheckAPIStatusCode to isolate APICall's logic
        Mock -CommandName 'CheckAPIStatusCode' -MockWith {
            param($response)
            return $response # By default, just pass the response through
        } | Out-Null
    }

    It 'should call Invoke-WebRequest with only a URL when no filepath is provided' {
        $testUrl = 'https://example.com'
        $mockResponse = [pscustomobject]@{ StatusCode = 200 }

        # Expect Invoke-WebRequest to be called with specific parameters
        Mock -CommandName 'Invoke-WebRequest' -ParameterFilter { $Uri -eq $testUrl -and -not $PSBoundParameters.ContainsKey('outfile') } -MockWith { return $mockResponse }

        $result = APICall -url $testUrl
        $result | Should -Be $mockResponse
        Assert-VerifiableMocks
    }

}