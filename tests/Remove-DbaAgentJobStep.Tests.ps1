$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandPath" -ForegroundColor Cyan
. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        [object[]]$params = (Get-Command $CommandName).Parameters.Keys | Where-Object {$_ -notin ('whatif', 'confirm')}
        [object[]]$knownParameters = 'SqlInstance', 'SqlCredential', 'Job', 'StepName', 'Mode', 'EnableException'
        $knownParameters += [System.Management.Automation.PSCmdlet]::CommonParameters
        It "Should only contain our specific parameters" {
            (@(Compare-Object -ReferenceObject ($knownParameters | Where-Object {$_}) -DifferenceObject $params).Count ) | Should Be 0
        }
    }
}

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Should remove agent job step" {
        BeforeAll {
            $null = New-DbaAgentJob -SqlInstance $script:instance2 -Job 'dbatoolsci_removeagentstep' -OwnerLogin 'sa'
            $null = New-DbaAgentJobStep -SqlInstance $script:instance2 -Job 'dbatoolsci_removeagentstep' -StepId 1 -StepName 'dbatoolsci_removestep' -Subsystem TransactSql -SubsystemServer $script:instance2 -Command "SELECT * FROM master.sys.all_columns;" -CmdExecSuccessCode 0 -OnSuccessAction QuitWithSuccess -OnFailAction QuitWithFailure -Database master -DatabaseUser sa

        }
        AfterAll {
            $null = Remove-DbaAgentJob -SqlInstance $script:instance2 -Job 'dbatoolsci_removeagentstep'
        }

        $results = Get-DbaAgentJobStep -SqlInstance $script:instance2 -Job 'dbatoolsci_removeagentstep'
        It "Should find all created job steps" {
            $results | Should Not BeNullOrEmpty
        }

        Remove-DbaAgentJobStep -SqlInstance $script:instance2 -Job 'dbatoolsci_removeagentstep' -StepName 'dbatoolsci_removestep'
        $results = Get-DbaAgentJobStep -SqlInstance $script:instance2 -Job 'dbatoolsci_removeagentstep'
        It "Should not find 'dbatoolsci_removestep' on dbatoolsci_removeagentstep" {
            $results | Should BeNullOrEmpty
        }

    }
    Context "Should remove agent job step with lazy mode" {
        BeforeAll {
            $null = New-DbaAgentJob -SqlInstance $script:instance2 -Job 'dbatoolsci_removeagentstep' -OwnerLogin 'sa'
            $null = New-DbaAgentJobStep -SqlInstance $script:instance2 -Job 'dbatoolsci_removeagentstep' -StepId 1 -StepName 'dbatoolsci_removelazystep' -Subsystem TransactSql -SubsystemServer $script:instance2 -Command "SELECT * FROM master.sys.all_columns;" -CmdExecSuccessCode 0 -OnSuccessAction QuitWithSuccess -OnFailAction QuitWithFailure -Database master -DatabaseUser sa

        }
        AfterAll {
            $null = Remove-DbaAgentJob -SqlInstance $script:instance2 -Job 'dbatoolsci_removeagentstep'
        }

        Remove-DbaAgentJobStep -SqlInstance $script:instance2 -Job 'dbatoolsci_removeagentstep' -StepName 'dbatoolsci_removelazystep' -Mode Lazy
        $results = Get-DbaAgentJobStep -SqlInstance $script:instance2 -Job 'dbatoolsci_removeagentstep'
        It "Should not find 'dbatoolsci_removelazystep' on dbatoolsci_removeagentstep" {
            $results | Should BeNullOrEmpty
        }
    }
    Context "Should remove agent job step with Report mode" {
        BeforeAll {
            $null = New-DbaAgentJob -SqlInstance $script:instance2 -Job 'dbatoolsci_removeagentstep' -OwnerLogin 'sa'
            $null = New-DbaAgentJobStep -SqlInstance $script:instance2 -Job 'dbatoolsci_removeagentstep' -StepId 1 -StepName 'dbatoolsci_removereportstep' -Subsystem TransactSql -SubsystemServer $script:instance2 -Command "SELECT * FROM master.sys.all_columns;" -CmdExecSuccessCode 0 -OnSuccessAction QuitWithSuccess -OnFailAction QuitWithFailure -Database master -DatabaseUser sa

        }
        AfterAll {
            $null = Remove-DbaAgentJob -SqlInstance $script:instance2 -Job 'dbatoolsci_removeagentstep'
        }

        Remove-DbaAgentJobStep -SqlInstance $script:instance2 -Job 'dbatoolsci_removeagentstep' -StepName 'dbatoolsci_removereportstep' -Mode Report
        $results = Get-DbaAgentJobStep -SqlInstance $script:instance2 -Job 'dbatoolsci_removeagentstep'
        It "Should not find 'dbatoolsci_removereportstep' on dbatoolsci_removeagentstep" {
            $results | Should BeNullOrEmpty
        }
    }
    Context "Should remove agent job step with Strict mode" {
        BeforeAll {
            $null = New-DbaAgentJob -SqlInstance $script:instance2 -Job 'dbatoolsci_removeagentstep' -OwnerLogin 'sa'
            $null = New-DbaAgentJobStep -SqlInstance $script:instance2 -Job 'dbatoolsci_removeagentstep' -StepId 1 -StepName 'dbatoolsci_removestrictstep' -Subsystem TransactSql -SubsystemServer $script:instance2 -Command "SELECT * FROM master.sys.all_columns;" -CmdExecSuccessCode 0 -OnSuccessAction QuitWithSuccess -OnFailAction QuitWithFailure -Database master -DatabaseUser sa

        }
        AfterAll {
            $null = Remove-DbaAgentJob -SqlInstance $script:instance2 -Job 'dbatoolsci_removeagentstep'
        }

        Remove-DbaAgentJobStep -SqlInstance $script:instance2 -Job 'dbatoolsci_removeagentstep' -StepName 'dbatoolsci_removestrictstep' -Mode Strict
        $results = Get-DbaAgentJobStep -SqlInstance $script:instance2 -Job 'dbatoolsci_removeagentstep'
        It "Should not find 'dbatoolsci_removestrictstep' on dbatoolsci_removeagentstep" {
            $results | Should BeNullOrEmpty
        }
    }
}