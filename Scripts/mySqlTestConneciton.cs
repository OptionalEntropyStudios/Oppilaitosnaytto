using Godot;
using System;
using MySql.Data;
using MySql.Data.MySqlClient;
using Org.BouncyCastle.Security;
public partial class mySqlTestConneciton : Node
{
	MySqlConnection connection;
	string connectionString = "SERVER=localhost;PORT=3306;DATABASE=peli_tietokanta;UID=root;PASSWORD=";
	public string userStats;
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		connection = new MySqlConnection(connectionString);
		connection.Open();
		string query = "SELECT * FROM player WHERE username = 'OptionalEntropy'";
		MySqlCommand command = connection.CreateCommand();
		command.CommandText = query;
		MySqlDataReader reader = command.ExecuteReader();


		if (reader.HasRows)
		{
			while (reader.Read())
			{
				string username = reader.GetString("username");
				string credits = Convert.ToString(reader.GetInt32("credits"));
				string accuracy = Convert.ToString(reader.GetFloat("accuracy"));
				int destroyedRobots = reader.GetInt32("destroyedRobots");
				userStats = $"Username: {username}, Credits: {credits}, Accuracy: {accuracy}, Destroyed Robots: {destroyedRobots}";
			}
		}
    }

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}
