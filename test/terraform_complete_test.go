package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformCompleteExample(t *testing.T) {
	terraformOptions := &terraform.Options{
		// website::tag::1:: Set the path to the Terraform code that will be tested.
		TerraformDir: "../examples/complete",

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	}

	// website::tag::4:: Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// website::tag::2:: Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// website::tag::3:: Run `terraform output` to get the values of output variables and check they have the expected values.
	outputNodeGroupIamRoleArn := terraform.Output(t, terraformOptions, "node_group_iam_role_arn")
	outputMapRoles := terraform.OutputList(t, terraformOptions, "map_roles")
	outputMapUsers := terraform.OutputList(t, terraformOptions, "map_users")
	outputMapAccounts := terraform.OutputList(t, terraformOptions, "map_accounts")

	expectedMapRoles := []string([]string{
		"map[groups:[system:bootstrappers system:nodes] rolearn:" + outputNodeGroupIamRoleArn + " username:system:node:{{EC2PrivateDNSName}}]",
	})
	expectedMapUsers := []string{}
	expectedMapAccounts := []string{}

	assert.Equal(t, expectedMapRoles, outputMapRoles, "Map %q should match %q", expectedMapRoles, expectedMapRoles)
	assert.Equal(t, expectedMapUsers, outputMapUsers, "Map %q should match %q", expectedMapUsers, outputMapUsers)
	assert.Equal(t, expectedMapAccounts, outputMapAccounts, "Map %q should match %q", expectedMapAccounts, outputMapAccounts)

	// website::tag::4:: Run a second "terraform apply". Fail the test if results have changes
	terraform.ApplyAndIdempotent(t, terraformOptions)
}
