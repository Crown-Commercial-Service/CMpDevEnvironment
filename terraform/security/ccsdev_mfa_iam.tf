##############################################################
#
# CCSDEV MFA IAM Configuration
#
# This script defines user/group related MFA IAM assets
#
#   Polices
#     CCS_manageown_mfa_device
#   Roles
#   Groups
#     CCS_MFA_ManageOwnDevice
#
#   Users?
#
##############################################################

resource "aws_iam_group" "CCS_MFA_ManageOwnDevice" {
  name = "CCS_MFA_ManageOwnDevice"
}

resource "aws_iam_policy" "CCS_manageown_mfa_device" {
  name   = "CCS_manageown_mfa_device"
  path   = "/"
  policy = "${data.aws_iam_policy_document.CCS_manageown_mfa_device.json}"
}

data "aws_iam_policy_document" "CCS_manageown_mfa_device" {
  statement {
    sid = "AllowManageOwnVirtualMFADevice"

    effect = "Allow"

    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
    ]

    resources = [
      "arn:aws:iam::*:mfa/&{aws:username}",
    ]
  }

  statement {
    sid = "AllowManageOwnUserMFA"

    effect = "Allow"

    actions = [
      "iam:DeactivateMFADevice",
      "iam:EnableMFADevice",
      "iam:ListMFADevices",
      "iam:ResyncMFADevice",
    ]

    resources = [
      "arn:aws:iam::*:user/&{aws:username}",
    ]
  }
  
  statement {
    sid = "BlockMostAccessUnlessSignedInWithMFA"

    effect = "Deny"

    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:ListVirtualMFADevices",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
      "iam:ListAccountAliases",
      "iam:ListUsers",
      "iam:ListSSHPublicKeys",
      "iam:ListAccessKeys",
      "iam:ListServiceSpecificCredentials",
      "iam:ListMFADevices",
      "iam:GetAccountSummary",
      "sts:GetSessionToken"
    ]

    resources = [
      "*",
    ]

    condition {
      test = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values = [
          "false",
        ]
    }
  }
}

resource "aws_iam_group_policy_attachment" "CCS_manageown_mfa_device" {
  group      = "${aws_iam_group.CCS_MFA_ManageOwnDevice.name}"
  policy_arn = "${aws_iam_policy.CCS_manageown_mfa_device.arn}"
}
