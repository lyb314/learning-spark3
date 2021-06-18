import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}

object WordCount {
  def main(args: Array[String]): Unit = {
    val conf: SparkConf = new SparkConf().setAppName("spark word count").setMaster("local[*]")

    val sc = new SparkContext(conf)
    val path = this.getClass.getResource("/").getPath()
    val inputStream: RDD[String] = sc.textFile(path + "log4j.properties")
    val result: String = inputStream.flatMap(_.split(" "))
      .map((_, 1))
      .reduceByKey(_ + _)
      .collect().mkString(",")
    println(result)

  }
}
