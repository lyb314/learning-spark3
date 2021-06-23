import java.net.URL
import java.text.SimpleDateFormat

import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}

object TransformOperator {
  def main(args: Array[String]): Unit = {
    val conf: SparkConf = new SparkConf().setMaster("local[*]").setAppName("TransformOperator")

    val sc: SparkContext = new SparkContext(conf)
    val url: URL = this.getClass.getResource("/LoginLog.csv")
    val inputStream: RDD[String] = sc.textFile(url.getPath)
    val mapLoginlog: RDD[LoginLog] = inputStream.map(line => {
      val strings: Array[String] = line.split(",")
      LoginLog(strings(0).toInt, strings(1), strings(2), strings(3).toLong * 1000)
    })
    val sortLoginLog: RDD[LoginLog] = mapLoginlog.sortBy(_.id)
    val newMapLoginLog: RDD[(String, Int, String, String)] = sortLoginLog.map(info => {
      val formatTime: String = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(info.time)
      (formatTime, info.id, info.ip, info.status)
    })
    val filterWithMap: RDD[(String, (String, Int, String))] = newMapLoginLog.filter(_._4 == "fail").map(line => {
      ((line._3, (line._1, line._2, line._4)))
    })
    val value: RDD[(String, Int)] = filterWithMap.map(line => {
      (line._1, 1)
    })
    val finalResult: Array[(String, Int)] = value.reduceByKey(_ + _).sortByKey().filter(_._2 > 1).collect()
    for (elem <- finalResult) {
      val message: String = "异常ip为："
      println(message + elem._1)
    }
    sc.stop()
  }
}
