module Kerbi

  ##
  # Convenience accessor struct for getting values from
  # the CLI args.
  class CliOpts

    attr_reader :options

    def initialize(options={})
      @options = options.deep_dup.freeze
    end

    def output_format
      value = options[consts::OUTPUT_FMT]
      value || "yaml"
    end

    def outputs_yaml?
      self.output_format == 'yaml'
    end

    def outputs_json?
      self.output_format == 'json'
    end

    def ruby_version
      options[consts::RUBY_VER]
    end

    def fname_exprs
      options[consts::VALUE_FNAMES] || []
    end

    def inline_val_exprs
      options[consts::INLINE_ASSIGNMENT] || []
    end

    def read_state_from
      options[consts::USE_STATE_VALUES].presence
    end

    def verbose?
      options[consts::VERBOSE]
    end

    def reads_state?
      read_state_from.present?
    end

    def k8s_auth_type
      options[consts::K8S_AUTH_TYPE] || "kube-config"
    end

    def kube_config_path
      options[consts::KUBE_CONFIG_PATH]
    end

    def kube_context_name
      options[consts::KUBE_CONFIG_CONTEXT]
    end

    def cluster_namespace
      options[consts::NAMESPACE]  || 'default'
    end

    def state_backend_type
      options[consts::STATE_BACKEND_TYPE] || "configmap"
    end

    def k8s_auth_username
      options[consts::K8S_USERNAME]
    end

    def k8s_auth_password
      options[consts::K8S_PASSWORD]
    end

    def k8s_auth_token
      options[consts::K8S_TOKEN]
    end

    private

    def consts
      Kerbi::Consts::OptionKeys
    end

  end
end