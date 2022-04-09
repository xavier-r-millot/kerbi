
# Kerbi

[![codecov](https://codecov.io/gh/nectar-cs/kerbi/branch/master/graph/badge.svg)](https://codecov.io/gh/nectar-cs/kerbi)
[![Gem Version](https://badge.fury.io/rb/kerbi.svg)](https://badge.fury.io/rb/kerbi)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Kerbi is a Kubernetes tool most similar to [Helm](https://helm.sh/). It does two things:
1. **Variable-based templating** based on ERB (YAML/JSON embedded Ruby)
2. **State management** for the applied variables, reading/writing to a `ConfigMap`, `Secret`, or database


## Getting Started

**[Complete guide and more.](https://xavier-9.gitbook.io/untitled/walkthroughs/getting-started)**

Install the `kerbi` RubyGem globally: 

```bash
$ gem install kerbi
```

Now use the new `kerbi` executable to initialize a project and install the dependencies:

```bash
$ kerbi project new hello-kerbi
$ cd hello-kerbi
```

Voila. Generate your first manifest with:

```yaml
$ kerbi template demo --set message=special
text: special demo message
```

And setup state managment in one line:

```bash
$ kerbi state init --namespace demo

$ kerbi template demo --write-state @candidate

$ kerbi state list
```


## Drawing from Helm, Kaptain, and CDK8s

### 💲 Variable/Value Based like Helm

Like with Helm, your control knobs are key-value pairs that get passed in at runtime,
which your templating logic uses to interpolate the final manifest. Your have your 
baseline `values.yaml` file, override files passed via CLI, e.g
`-f production.yaml`, and inline assignments, e.g `--set backend.ingress.enabled=false`.

**`production.yaml`**
```yaml
backend:
  deployment:
    replicas: 30
```

Zero innovation here because Helm does it perfectly.

### 📜 Familiar Ruby in YAML Templating ~~New Dialects or Object Models~~

Helm's Go-in-YAML might be awkward, but makes the right choice of sticking to Kubernetes' lingua franca - YAML.
Kapitan and CDK8S offer a better DX, but only if you 1) know their DSL/libs well,
and 2) actually need hardcore templating everywhere in your project.

**`deployment.yaml.erb`**
```yaml
apiVersion: appsV1
kind: Deployment
metadata:
  name: <% Hooli::Backend::Consts::NAME %>
  namespace: <%= release_name %>
  labels: <%= embed(common_labels) %>
spec: 
  replicas: <%= values[:deployment][:replicas] %>
  template:
    spec:
      containers: <%= embed_array(
                        file('containers') + 
                        mixer(Hooli::Traefik::ContainerMixer))
                   ) %>
```

### 📀 Explicit, Transparent, Robust State Management

```bash
$ kerbi template my-app \
        --set backend.image=thing:1.0.1 \
        --read-state @latest \
        --write-state @candidate \       
        >> manifest.yaml
```

```
table
```

### 🚦 Powerful Templating Orchestration Layer

**`backend/mixer.rb`**
```ruby
class MyApp::Backend::Mixer < Kerbi::Mixer
  include Hooli::Common::KubernetesLabels
  values_root "backend"

  def mix
    push file("deployment")
    push file("pvc") if persistence_enabled?
    push(mixer(ServiceMixer) + file("ingress"))
    
    patched_with file("annotations") do
      push chart("my-legacy/helm-chart")
      push dir("./../rbac", only: [{kind: 'ClusterRole.*'}])
    end
  end 
  
  def persistence_enabled?
    values.dig(:database, :enabled).present?
  end
end
```

### 🗣️ No talking to Kubernetes behind your back

```bash
$ kerbi config use-namespace see-food
$ kerbi state test-connection
$ kerbi state init
$ kerbi state test-connection
```

## ⌨️ Interactive Console
 
Kerbi can also be run in interactive mode (via IRB), making it super easy to play
with your code and debug things:

```ruby
$ kerbi console --set backend.database.enabled=true

irb(kerbi):001:0> values
=> {:backend=>{:database=>{:enabled=>"true"}}}

irb(kerbi):002:0> Hooli::Backend::Mixer.new(values).persistence_enabled?
=> true

irb(kerbi):003:0> Hooli::Backend::Mixer.new(values).run
=> [{:apiVersion=>"appsV1", :kind=>"Deployment", :metadata=>{:name=>"backend", :namespace=>"default"}, :spec=>"foo"}]
```

## Getting Involved

If you're interesting in getting involved, thank you ❤️. 

[CONTRIBUTING.md](https://github.com/nmachine-io/kerbi/blob/master/CONTRIBUTING.md)

Email: xavier@nmachine.io

Discord: https://discord.gg/ntAs6TaD

# Running the Examples

Have a look at the [examples](https://github.com/nmachine-io/kerbi/tree/master/examples) directory. 
If you want to go a step further and run them from source, clone the project, `cd` into the example you 
want. For instance:

```bash
$ cd examples/hello-kerbi
$ kerbi template default .
```
