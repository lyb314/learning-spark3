import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}

object WordCount {
  def main(args: Array[String]): Unit = {
    val conf: SparkConf = new SparkConf().setAppName("spark word count").setMaster("local[*]")

    val sc = new SparkContext(conf)
    val path = this.getClass.getResource("/").getPath()
    val inputSteam  = sc.textFile(path + "log4j.properties")
      .flatMap(_.split("\\s"))
      .map((_, 1))
      .reduceByKey(_ + _)
    val result = inputSteam.collect()
    result.foreach(println)
  }
}
