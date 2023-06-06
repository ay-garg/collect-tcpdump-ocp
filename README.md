# collect-tcpdump-ocp
DaemonSet to collect PCAPs for all interfaces on each OpenShift 4 cluster nodes.
The PCAP will be getting captured for exact 1 minute once the pod comes up and the pods will be getting restarted after 10 minutes to again capture the PCAPs on nodes.

## The `collect-tcpdump-ocp` daemonset collects TCPDUMP on each node with following command at the path `/tmp/tcpdump/` on the node itself.
```
# tcpdump -nn -s 0 -i any -w /tmp/tcpdump/${HOSTNAME}_$(date +%d_%m_%Y-%H_%M_%S-%Z).pcap
```

## How to use the daemonset?

### Create a new project to deploy the daemonset and add the `default` service account to the privileged SCC so pods can come up.
```
# oc new-project collect-tcpdump-ocp
# oc adm policy add-scc-to-user privileged -z default
```

### Deploy the `tcpdump-daemonset.yaml`.
```
# oc create -f tcpdump-daemonset.yaml
```

### Wait for at least 1 minute for pods to capture PCAPs.
```
$ oc get pod
NAME                        READY   STATUS    RESTARTS   AGE
collect-tcpdump-ocp-dnc68   1/1     Running   0          4m22s
collect-tcpdump-ocp-j8dqp   1/1     Running   0          4m26s
collect-tcpdump-ocp-krgr5   1/1     Running   0          4m26s
collect-tcpdump-ocp-kx5sd   1/1     Running   0          4m25s
collect-tcpdump-ocp-scrgt   1/1     Running   0          4m22s
collect-tcpdump-ocp-xg6zs   1/1     Running   0          4m22s
```

### Copy the PCAP files from all OCP nodes via SCP command for which the SSH private key is needed.
```
// Fetch all the nodes name.
# nodes="$(oc get nodes -o jsonpath='{.items[*].metadata.name}')"

// SCP the PCAPs from nodes.
# for pcap in $(echo $nodes); do scp -i <private-ssh-key-path> core@${pcap}:/tmp/tcpdump/*.pcap /<destination-dir-to-save-pcap>; done
```

### Delete the PCAPs from nodes once copied and delete the project as well in which daemonset was deployed.
```
# for pcap in $(echo $PCAPs); do ssh -i <private-ssh-key-path> core@${pcap} sudo rm -rf /tmp/tcpdump/; done
# oc delete project collect-tcpdump-ocp
```
