spark learning-note

spark 运行模式
Local 模式 ：所谓的 Local 模式，就是不需 要其他任何节点资源就可以在本地执行 Spark 代码的环境，
            一般用于教学，调试，演示等，之前在 IDEA 中运行代码的环境我们称之为开发环境，不太一样。
Standalone 模式: 只使用 Spark 自身节点运行的集群模式，也就是我们所谓的
                独立部署（Standalone）模式。Spark 的 Standalone 模式体现了经典的 master-slave 模式。
Yarn 模式 :独立部署（Standalone）模式由 Spark 自身提供计算资源，无需其他框架提供资源。这
            种方式降低了和其他第三方资源框架的耦合性，独立性非常强。但是你也要记住，Spark 主
            要是计算框架，而不是资源调度框架，所以本身提供的资源调度并不是它的强项，所以还是
            和其他专业的资源调度框架集成会更靠谱一些。所以接下来我们来学习在强大的 Yarn 环境
            下 Spark 是如何工作的（其实是因为在国内工作中，Yarn 使用的非常多）。

4.2 核心组件
由上图可以看出，对于 Spark 框架有两个核心组件：
4.2.1 Driver
  Spark 驱动器节点，用于执行 Spark 任务中的 main 方法，负责实际代码的执行工作。
  Driver 在 Spark 作业执行时主要负责：
# shellcheck disable=SC1036
将用户程序转化为作业（job） 在 Executor 之间调度任务 Task
跟踪 Executor 的执行情况
 通过 UI 展示查询运行情况
实际上，我们无法准确地描述 Driver 的定义，因为在整个的编程过程中没有看到任何有关
Driver 的字眼。所以简单理解，所谓的 Driver 就是驱使整个应用运行起来的程序，也称之为
Driver 类。
4.2.2 Executor
Spark Executor 是集群中工作节点（Worker）中的一个 JVM 进程，负责在 Spark 作业
中运行具体任务（Task），任务彼此之间相互独立。Spark 应用启动时，Executor 节点被同
时启动，并且始终伴随着整个 Spark 应用的生命周期而存在。如果有 Executor 节点发生了
故障或崩溃，Spark 应用也可以继续执行，会将出错节点上的任务调度到其他 Executor 节点
上继续运行。
Executor 有两个核心功能：
➢ 负责运行组成 Spark 应用的任务，并将结果返回给驱动器进程
➢ 它们通过自身的块管理器（Block Manager）为用户程序中要求缓存的 RDD 提供内存式存储。RDD 是直接缓存在 Executor 进程内的，因此任务可以在运行时充分利用缓存数据加速运算。
4.2.3 Master & Worker
Spark 集群的独立部署环境中，不需要依赖其他的资源调度框架，自身就实现了资源调度的功能，所以环境中还有其他两个核心组件：Master 和 Worker，这里的 Master 是一个进
程，主要负责资源的调度和分配，并进行集群的监控等职责，类似于 Yarn 环境中的 RM, 而
Worker 呢，也是进程，一个 Worker 运行在集群中的一台服务器上，由 Master 分配资源对
数据进行并行的处理和计算，类似于 Yarn 环境中 NM。 4.2.4 ApplicationMaster
Hadoop 用户向 YARN 集群提交应用程序时,提交程序中应该包含 ApplicationMaster，用
于向资源调度器申请执行任务的资源容器 Container，运行用户自己的程序任务 job，监控整
个任务的执行，跟踪整个任务的状态，处理任务失败等异常情况。
说的简单点就是，ResourceManager（资源）和 Driver（计算）之间的解耦合靠的就是
ApplicationMaster。

4.3 核心概念
4.3.1 Executor 与 Core
Spark Executor 是集群中运行在工作节点（Worker）中的一个 JVM 进程，是整个集群中
的专门用于计算的节点。在提交应用中，可以提供参数指定计算节点的个数，以及对应的资
源。这里的资源一般指的是工作节点 Executor 的内存大小和使用的虚拟 CPU 核（Core）数
量。


提交模式

Yarn Client 模式
Client 模式将用于监控和调度的 Driver 模块在客户端执行，而不是在 Yarn 中，所以一
般用于测试。
➢ Driver 在任务提交的本地机器上运行
➢ Driver 启动后会和 ResourceManager 通讯申请启动 ApplicationMaster
➢ ResourceManager 分配 container，在合适的 NodeManager 上启动 ApplicationMaster，负责向 ResourceManager 申请 Executor 内存
➢ ResourceManager 接到 ApplicationMaster 的资源申请后会分配 container，然后ApplicationMaster 在资源分配指定的 NodeManager 上启动 Executor 进程
➢ Executor 进程启动后会向 Driver 反向注册，Executor 全部注册完成后 Driver 开始执行main 函数
➢ 之后执行到 Action 算子时，触发一个 Job，并根据宽依赖开始划分 stage，每个 stage 生成对应的 TaskSet，之后将 task 分发到各个 Executor 上执行。


Yarn Cluster 模式
Cluster 模式将用于监控和调度的 Driver 模块启动在 Yarn 集群资源中执行。一般应用于实际生产环境。
➢ 在 YARN Cluster 模式下，任务提交后会和 ResourceManager 通讯申请启动ApplicationMaster，
➢ 随后 ResourceManager 分配 container，在合适的 NodeManager 上启动 ApplicationMaster，此时的 ApplicationMaster 就是 Driver。
➢ Driver 启动后向 ResourceManager 申请 Executor 内存，ResourceManager 接到ApplicationMaster 的资源申请后会分配 container，然后在合适的 NodeManager 上启动Executor 进程
➢ Executor 进程启动后会向 Driver 反向注册，Executor 全部注册完成后 Driver 开始执行main 函数，
➢ 之后执行到 Action 算子时，触发一个 Job，并根据宽依赖开始划分 stage，每个 stage 生成对应的 TaskSet，之后将 task 分发到各个 Executor 上执行。


spark 核心编程，主要涉及三种数据结构：
      RDD:弹性分布式数据集
      累加器：分布式共享只写变量
      广播变量：分布式共享只读变量

RDD 特性：
➢ 弹性
    ⚫ 存储的弹性：内存与磁盘的自动切换；
    ⚫ 容错的弹性：数据丢失可以自动恢复；
    ⚫ 计算的弹性：计算出错重试机制；
    ⚫ 分片的弹性：可根据需要重新分片。
➢ 分布式：数据存储在大数据集群不同节点上
➢ 数据集：RDD 封装了计算逻辑，并不保存数据
➢ 数据抽象：RDD 是一个抽象类，需要子类具体实现
➢ 不可变：RDD 封装了计算逻辑，是不可以改变的，想要改变，只能产生新的 RDD，在新的 RDD 里面封装计算逻辑
➢ 可分区、并行计算

