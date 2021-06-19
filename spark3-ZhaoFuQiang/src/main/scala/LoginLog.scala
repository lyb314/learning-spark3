import org.apache.spark.sql.execution.streaming.FileStreamSource.Timestamp

case class LoginLog(
                     id: Int,
                     ip: String,
                     status: String,
                     time: Long
                   )
