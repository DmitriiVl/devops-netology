# Ответы на задания 13-kubenet-03-k8sappupdate 

### Цель задания

Выбрать и настроить стратегию обновления приложения.

### Чеклист готовности к домашнему заданию

1. Кластер K8s.

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Документация Updating a Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#updating-a-deployment).
2. [Статья про стратегии обновлений](https://habr.com/ru/companies/flant/articles/471620/).

-----

### Задание 1. Выбрать стратегию обновления приложения и описать ваш выбор

1. Имеется приложение, состоящее из нескольких реплик, которое требуется обновить.
2. Ресурсы, выделенные для приложения, ограничены, и нет возможности их увеличить.
3. Запас по ресурсам в менее загруженный момент времени составляет 20%.
4. Обновление мажорное, новые версии приложения не умеют работать со старыми.
5. Вам нужно объяснить свой выбор стратегии обновления приложения.

### Задание 2. Обновить приложение

1. Создать deployment приложения с контейнерами nginx и multitool. Версию nginx взять 1.19. Количество реплик — 5.
2. Обновить версию nginx в приложении до версии 1.20, сократив время обновления до минимума. Приложение должно быть доступно.
3. Попытаться обновить nginx до версии 1.28, приложение должно оставаться доступным.
4. Откатиться после неудачного обновления.

---

### Ответ к заданию 1  

В ситуации ограниченности ресурсов наиболее подходящим видится использование стратегии *Recreate*, однако, такой подход может нести в себе риски в случае, если что-то пойдет не так, а также существует вероятность простоя. Для того, чтобы данные риски нивелировать предпочтительнее использовать другую стратегию. По условиям задания в менее загруженный момент времени запас по ресурсам составляет 20%, таким образом обновление лучше планировать на время, когда нагрузка минимальна, используя параметры *maxSurge* и *maxUnavailable* для нахождения в рамках выделенных мощностей. Кроме того, в условии задачи указано, что обоновление мажорое (то есть изменения ожидаются существенные), что дает нам повод предполагать, что максимально подходящей для этого типа обновления будет *Blue-green* стратегия, как самая надежная, но бюджето-затратная. Таким образом я, если бы стоял перед выбором делал бы следующее:

1. Если приложение коммерчески плавучее - пошел бы к руководству обосновывать дополнительный бюджет и остановился бы на стратегии *Blue-green*.
2. Если шансов на дополнительное финансирование нет (образовательный/благотворительный проект) - использовал бы *Rolling update* в наименее нагруженное время, используя вышеупомянутые параметры.  

### Ответ к заданию 2  

Создаем NS со следующим именем и изменяем контекст по умолчанию:  

```bash
kubectl create namespace 13-kubenet-03-k8sappupdate
kubectl config set-context --current --namespace=13-kubenet-03-k8sappupdate
```

Создаем манифест Deployment и Service для разворачивания приложения:  

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: netology-deployment
  namespace: 13-kubenet-03-k8sappupdate
spec:
  replicas: 5
  selector:
    matchLabels:
      app: netology-deployment
  template:
    metadata:
      labels:
        app: netology-deployment
    spec:
      containers:
      - name: nginx
        image: nginx:1.19
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 80
      - name: multitool
        image: wbitt/network-multitool
        env:
        - name: HTTP_PORT
          value: "8080"
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 8080

---
apiVersion: v1
kind: Service
metadata:
  name: netology-svc
  namespace: 13-kubenet-03-k8sappupdate
spec:
  selector:
    app: netology-deployment
  ports:
  - name: nginx-port
    port: 9001
    targetPort: 80
  - name: multitool-port
    port: 9002
    targetPort: 8080

```  

Далее проверяем работоспособность и доступность подов и сервиса:  

```bash
dmivlad@k8s-node-master:~/K8S_homeworks/13-kubenet-03-k8sappupdate$ kubectl get pods
NAME                                   READY   STATUS    RESTARTS   AGE
netology-deployment-6844754674-5fr6w   2/2     Running   0          2m53s
netology-deployment-6844754674-5kgt2   2/2     Running   0          2m53s
netology-deployment-6844754674-6v9h2   2/2     Running   0          2m53s
netology-deployment-6844754674-mr7rj   2/2     Running   0          2m53s
netology-deployment-6844754674-zt8vn   2/2     Running   0          2m53s
dmivlad@k8s-node-master:~/K8S_homeworks/13-kubenet-03-k8sappupdate$ kubectl get svc
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
netology-svc   ClusterIP   10.108.174.17   <none>        9001/TCP,9002/TCP   2m54s
```

Пишем манифест для обновления, параметры maxSurge и maxUnavailable выбираем, исходя из условий задачи:  

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: netology-deployment
  namespace: 13-kubenet-03-k8sappupdate
spec:
  replicas: 5
  strategy: 
    rollingUpdate:
      maxSurge: 20%
      maxUnavailable: 80%
  selector:
    matchLabels:
      app: netology-deployment
  template:
    metadata:
      labels:
        app: netology-deployment
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 80
```  

Приложения во время обновления оставались доступными. Проверяем как прошло обновление, получая следущий вывод команд:  

```bash
dmivlad@k8s-node-master:~/K8S_homeworks/13-kubenet-03-k8sappupdate$ kubectl get pods
NAME                                   READY   STATUS    RESTARTS   AGE
netology-deployment-55bf4dc958-5kvzw   2/2     Running   0          25s
netology-deployment-55bf4dc958-6fccr   2/2     Running   0          25s
netology-deployment-55bf4dc958-nw5xj   2/2     Running   0          25s
netology-deployment-55bf4dc958-pw8m9   2/2     Running   0          25s
netology-deployment-55bf4dc958-w8npr   2/2     Running   0          25s
dmivlad@k8s-node-master:~/K8S_homeworks/13-kubenet-03-k8sappupdate$ kubectl describe pod netology-deployment-55bf4dc958-w8npr
Name:             netology-deployment-55bf4dc958-w8npr
Namespace:        13-kubenet-03-k8sappupdate
Priority:         0
Service Account:  default
Node:             k8s-node-worker3/192.168.155.27
Start Time:       Sun, 11 Feb 2024 16:21:00 +0300
Labels:           app=netology-deployment
                  pod-template-hash=55bf4dc958
Annotations:      cni.projectcalico.org/containerID: ce36fb0f9966e992ff0e8fa07561bee65085234823b57e6edd1f0958896ab488
                  cni.projectcalico.org/podIP: 10.244.45.200/32
                  cni.projectcalico.org/podIPs: 10.244.45.200/32
Status:           Running
IP:               10.244.45.200
IPs:
  IP:           10.244.45.200
Controlled By:  ReplicaSet/netology-deployment-55bf4dc958
Containers:
  nginx:
    Container ID:   containerd://1b2a4a77fdc3f997b259af8e5957699151f46a6b7f45407b81b3f79576bf6b80
    Image:          nginx:1.20
    Image ID:       docker.io/library/nginx@sha256:38f8c1d9613f3f42e7969c3b1dd5c3277e635d4576713e6453c6193e66270a6d
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Sun, 11 Feb 2024 16:21:22 +0300
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     500m
      memory:  128Mi
    Requests:
      cpu:        500m
      memory:     128Mi
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-9d9pq (ro)
  multitool:
    Container ID:   containerd://62ab398df9d9f6bbaa27d4f71cf22f33aa453564595dc8bc51029726700dd90a
    Image:          wbitt/network-multitool
    Image ID:       docker.io/wbitt/network-multitool@sha256:d1137e87af76ee15cd0b3d4c7e2fcd111ffbd510ccd0af076fc98dddfc50a735
    Port:           8080/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Sun, 11 Feb 2024 16:21:24 +0300
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     500m
      memory:  128Mi
    Requests:
      cpu:     500m
      memory:  128Mi
    Environment:
      HTTP_PORT:  8080
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-9d9pq (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-9d9pq:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Guaranteed
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  40s   default-scheduler  Successfully assigned 13-kubenet-03-k8sappupdate/netology-deployment-55bf4dc958-w8npr to k8s-node-worker3
  Normal  Pulling    38s   kubelet            Pulling image "nginx:1.20"
  Normal  Pulled     20s   kubelet            Successfully pulled image "nginx:1.20" in 18.511s (18.511s including waiting)
  Normal  Created    19s   kubelet            Created container nginx
  Normal  Started    19s   kubelet            Started container nginx
  Normal  Pulling    19s   kubelet            Pulling image "wbitt/network-multitool"
  Normal  Pulled     18s   kubelet            Successfully pulled image "wbitt/network-multitool" in 1.214s (1.214s including waiting)
  Normal  Created    17s   kubelet            Created container multitool
  Normal  Started    17s   kubelet            Started container multitool
```

Пытаемся обновить образ nginx на версию 1.28, приложение остается доступным, получаем следующий результат:  

```bash
dmivlad@k8s-node-master:~/K8S_homeworks/13-kubenet-03-k8sappupdate$ kubectl get pods
NAME                                   READY   STATUS             RESTARTS   AGE
netology-deployment-55bf4dc958-w8npr   2/2     Running            0          5m12s
netology-deployment-866cf4d686-772dh   1/2     ImagePullBackOff   0          3m18s
netology-deployment-866cf4d686-7bsmj   1/2     ErrImagePull       0          3m18s
netology-deployment-866cf4d686-85cdx   1/2     ImagePullBackOff   0          3m19s
netology-deployment-866cf4d686-fdlfn   1/2     ErrImagePull       0          3m18s
netology-deployment-866cf4d686-x497r   1/2     ImagePullBackOff   0          3m18s
```

Подтверждаем доступность приложения:  

```bash
dmivlad@k8s-node-master:~/K8S_homeworks/13-kubenet-03-k8sappupdate$ kubectl exec deployment/netology-deployment -- curl netology-svc:9001
Defaulted container "nginx" out of: nginx, multitool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
100   612  100   612    0     0   2637      0 --:--:-- --:--:-- --:--:--  2637
```

Откатываемся к предыдущей версии образа:  

```bash
dmivlad@k8s-node-master:~/K8S_homeworks/13-kubenet-03-k8sappupdate$ kubectl rollout undo deployment netology-deployment
deployment.apps/netology-deployment rolled back
dmivlad@k8s-node-master:~/K8S_homeworks/13-kubenet-03-k8sappupdate$ kubectl get pods
NAME                                   READY   STATUS    RESTARTS   AGE
netology-deployment-55bf4dc958-626ln   2/2     Running   0          14s
netology-deployment-55bf4dc958-bh2q8   2/2     Running   0          14s
netology-deployment-55bf4dc958-jm8q5   2/2     Running   0          14s
netology-deployment-55bf4dc958-m5qmx   2/2     Running   0          14s
netology-deployment-55bf4dc958-w8npr   2/2     Running   0          9m29s
```