import org.apache.spark.{SparkConf, SparkContext}

object WordCount {
  def main(args: Array[String]): Unit = {
    val conf: SparkConf = new SparkConf().setAppName("spark word count").setMaster("local[*]")

    val sc = new SparkContext(conf)
    val path = this.getClass.getResource("/").getPath()
    val inputSteam = sc.textFile(path + "log4j.properties")
      .flatMap(_.split("\\s"))
      .map((_, 1))
      .reduceByKey(_ + _)

    val result = inputSteam.collect()
    //设置类型推断的
    result.foreach(println)

    //Shut down the SparkContext.，关闭执行环境
    //stop是停止appication的意思，spark是做垃圾回收，防止资源泄露。
    //关闭 Spark 连接

    sc.stop()
  }
}