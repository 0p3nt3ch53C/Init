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