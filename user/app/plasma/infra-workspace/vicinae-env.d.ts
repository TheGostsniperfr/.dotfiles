/// <reference types="@vicinae/api">

/*
 * This file is auto-generated from the extension's manifest.
 * Do not modify manually. Instead, update the `package.json` file.
 */

type ExtensionPreferences = {
  /** Terminal - Command prefix used to open a terminal, the command is appended */
	"terminal"?: string;
}

declare type Preferences = ExtensionPreferences

declare namespace Preferences {
  /** Command: Alertmanager */
	export type OpenAlertmanager = Omit<ExtensionPreferences, never> & {
		
	}

	/** Command: Vault */
	export type OpenVault = Omit<ExtensionPreferences, never> & {
		
	}

	/** Command: ArgoCD */
	export type OpenArgocd = Omit<ExtensionPreferences, never> & {
		
	}

	/** Command: Grafana */
	export type OpenGrafana = Omit<ExtensionPreferences, never> & {
		
	}

	/** Command: Infra */
	export type Infra = Omit<ExtensionPreferences, never> & {
		
	}

	/** Command: Switch Infra */
	export type SwitchInfra = Omit<ExtensionPreferences, never> & {
		
	}

	/** Command: Kube Pods */
	export type Kube = Omit<ExtensionPreferences, never> & {
		
	}

	/** Command: ArgoCD Apps */
	export type Argocd = Omit<ExtensionPreferences, never> & {
		
	}

	/** Command: Firing Alerts */
	export type Alerts = Omit<ExtensionPreferences, never> & {
		
	}

	/** Command: Grafana Dashboards */
	export type Grafana = Omit<ExtensionPreferences, never> & {
		
	}

	/** Command: GitLab Merge Requests */
	export type Gitlab = Omit<ExtensionPreferences, never> & {
		
	}

	/** Command: Talos */
	export type Talos = Omit<ExtensionPreferences, never> & {
		
	}

	/** Command: OpenStack Servers */
	export type Openstack = Omit<ExtensionPreferences, never> & {
		
	}

	/** Command: Boundary and Vault */
	export type Boundary = Omit<ExtensionPreferences, never> & {
		
	}

	/** Command: Runbooks */
	export type Runbooks = Omit<ExtensionPreferences, never> & {
		
	}
}

declare namespace ToolPreferences {
  
}

declare namespace Arguments {
  /** Command: Alertmanager */
	export type OpenAlertmanager = {
		
	}

	/** Command: Vault */
	export type OpenVault = {
		
	}

	/** Command: ArgoCD */
	export type OpenArgocd = {
		
	}

	/** Command: Grafana */
	export type OpenGrafana = {
		
	}

	/** Command: Infra */
	export type Infra = {
		
	}

	/** Command: Switch Infra */
	export type SwitchInfra = {
		
	}

	/** Command: Kube Pods */
	export type Kube = {
		
	}

	/** Command: ArgoCD Apps */
	export type Argocd = {
		
	}

	/** Command: Firing Alerts */
	export type Alerts = {
		
	}

	/** Command: Grafana Dashboards */
	export type Grafana = {
		
	}

	/** Command: GitLab Merge Requests */
	export type Gitlab = {
		
	}

	/** Command: Talos */
	export type Talos = {
		
	}

	/** Command: OpenStack Servers */
	export type Openstack = {
		
	}

	/** Command: Boundary and Vault */
	export type Boundary = {
		
	}

	/** Command: Runbooks */
	export type Runbooks = {
		
	}
}