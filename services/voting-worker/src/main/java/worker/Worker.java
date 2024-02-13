package worker;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.exceptions.JedisConnectionException;
import java.sql.*;
import org.json.JSONObject;
import java.util.Map;
import java.util.logging.Logger;
import java.util.logging.Level;

class Worker {
  static Logger logger = Logger.getAnonymousLogger();

  public static void main(String[] args) {
    try {
      Map<String, String> env = System.getenv();
      String postgresHost = env.get("PG_HOST");
      String postgresPasswd = env.get("PG_PASSWORD");
      String postgresUser = env.get("PG_USER");
      String postgresDatabase = env.get("PG_DATABASE");

      String redisHost = env.get("REDIS_HOST");
      String redisPasswd = env.get("REDIS_PASSWORD");

      Jedis redis = connectToRedis(redisHost, redisPasswd);
      Connection dbConn = connectToDB(postgresHost, postgresUser, postgresPasswd, postgresDatabase);

      System.err.println("Watching vote queue");

      while (true) {
        String voteJSON = redis.blpop(0, "votes").get(1);
        JSONObject voteData = new JSONObject(voteJSON);
        String voterID = voteData.getString("voter_id");
        String vote = voteData.getString("vote");

        System.err.printf("Processing vote for '%s' by '%s'\n", vote, voterID);
        updateVote(dbConn, voterID, vote);
      }
    } catch (SQLException e) {
      logger.log(Level.SEVERE, "Processing vote failed due to SQL error", e);;
      e.printStackTrace();
      System.exit(1);
    }
  }

  static void updateVote(Connection dbConn, String voterID, String vote) throws SQLException {
    PreparedStatement insert = dbConn.prepareStatement(
        "INSERT INTO votes (id, vote) VALUES (?, ?)");
    insert.setString(1, voterID);
    insert.setString(2, vote);

    try {
      insert.executeUpdate();
    } catch (SQLException e) {
      PreparedStatement update = dbConn.prepareStatement(
          "UPDATE votes SET vote = ? WHERE id = ?");
      update.setString(1, vote);
      update.setString(2, voterID);
      update.executeUpdate();
    }
  }

  static Jedis connectToRedis(String host, String password) {
    Jedis conn = new Jedis(host);

    while (true) {
      try {
        conn.auth(password);
        conn.keys("*");
        break;
      } catch (JedisConnectionException e) {
        System.err.println("Failed to connect to redis - retrying");
        sleep(1000);
      }
    }

    System.err.println("Connected to redis");
    return conn;
  }

  static Connection connectToDB(String host, String username, String password, String database) throws SQLException {
    Connection conn = null;

    try {

      Class.forName("org.postgresql.Driver");
      String url = "jdbc:postgresql://" + host + "/" + database;

      while (conn == null) {
        try {
          conn = DriverManager.getConnection(url, username, password);
        } catch (SQLException e) {
          logger.log(Level.SEVERE, "Unable to connect to DB", e);;
          System.err.println("Failed to connect to db - retrying");
          sleep(1000);
        }
      }

      PreparedStatement st = conn.prepareStatement(
          "CREATE TABLE IF NOT EXISTS votes (id VARCHAR(255) NOT NULL UNIQUE, vote VARCHAR(255) NOT NULL)");
      st.executeUpdate();

    } catch (ClassNotFoundException e) {
      e.printStackTrace();
      System.exit(1);
    }

    return conn;
  }

  static void sleep(long duration) {
    try {
      Thread.sleep(duration);
    } catch (InterruptedException e) {
      System.exit(1);
    }
  }
}
