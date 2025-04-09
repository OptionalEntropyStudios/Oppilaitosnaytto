using Godot;
using System;
using MySql.Data;
using MySql.Data.MySqlClient;
using Org.BouncyCastle.Security;
using Mysqlx.Crud;
using System.Web;
using System.Diagnostics;
public partial class mySqlTestConneciton : Node
{
	MySqlConnection connection;
	string connectionString = "SERVER=localhost;PORT=3306;DATABASE=peli_tietokanta;UID=root;PASSWORD=";

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
        connection = new MySqlConnection(connectionString);
    }

	public bool UsernameExists(string userName)
	{
		string query = $"SELECT * FROM player WHERE username = '{userName}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = query;
        MySqlDataReader reader = command.ExecuteReader();
        if (reader.HasRows)
        {
            reader.Close();
            connection.Close();
            return true;
        }
        else
        {
            reader.Close();
            connection.Close();
            return false;
        }
    }

    public void RegisterUser(string userName)
    {
        connection = new MySqlConnection(connectionString);
        connection.Open();
        string query = $"INSERT INTO player (username, credits, accuracy, destroyedRobots) VALUES ('{userName}', 100, 100, 0)";
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = query;
        command.ExecuteNonQuery();
        connection.Close();
    }

    //Check if the specified user own the specififed gun: pistol, smg or shotgun.
    //returns true, if there is an instance id with teh user's username and weapontype specified.
    public bool isOwned(string owner, string gunType)
    {
        string weaponInstanceID = owner + gunType;
        string query = $"SELECT * FROM weaponInstance WHERE instanceID = '{weaponInstanceID}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = query;
        MySqlDataReader reader = command.ExecuteReader();
        if (reader.HasRows)
        {
            reader.Close();
            connection.Close();
            return true;
        }
        else
        {
            reader.Close();
            connection.Close();
            return false;
        }
    }

    //Checks for any entries into the weaponupgrade table referencing the owned weapon.
    //Returns true, if the gun has any upgrades on it
    public bool HasUpgrades(string owner, string gunType)
    {
        string weaponInstanceID = owner + gunType;
        string query = $"SELECT * FROM weaponupgrade WHERE weaponinstanceID = '{weaponInstanceID}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = query;
        MySqlDataReader reader = command.ExecuteReader();
        if (reader.HasRows)
        {
            reader.Close();
            connection.Close();
            return true;
        }
        else
        {
            reader.Close();
            connection.Close();
            return false;
        }
    }
    //Add lvl 1 upgrades for bulletdamage, firerate, capacity and reloadspeed to an owned weapon.
    public void AddBaseUpgrades(string owner, string gunType)
    {

        string weapontype = getWeaponAbbreviation(gunType);

        string weaponInstanceID = owner + gunType; //The "owned" gun's id, which is just username + guntype
        
        //start of the query, 
        string query = $"INSERT INTO weaponupgrade " +
            $"(weaponinstanceid, upgradeid, upgradetype, upgradeprice, upgradelevel) VALUES ";

        //Each weaponupgrade has a unique integer id to differentiate them
        //bulletDamage = 1
        //firerate = 2
        //magazineSize = 3
        //reloadSpeed = 4

        //Create a query for each upgrade and set it's level to 1
        for (int i = 1; i <= 4; i++) {
            string upgradeID = owner + weapontype + i; //for example optionalentropypl1 or optionalentropysg3
            query += $"('{weaponInstanceID}', '{upgradeID}', '{i}', 100, 1)";
            if(i<4)
            {
                query += ",";
            }
        }
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = query;
        command.ExecuteNonQuery();
    }

    string getWeaponAbbreviation(string gunName)
    {
        if (gunName == "pistol")
        {
            return "pl";
        }
        else if (gunName == "smg")
        {
            return "sg";
        }
        else
        {
            return "sn";
        }
    }
    public int GetWeaponUpgradeLvl(string owner, string gunType , int upgradeType)
    {
        string weapontype = getWeaponAbbreviation(gunType);

        string targetUpgradeID = owner + weapontype + upgradeType.ToString();
        string upgradeLvlQuery = $"SELECT upgradelevel FROM weaponupgrade WHERE upgradeID = '{targetUpgradeID}'";

        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = upgradeLvlQuery;
        MySqlDataReader reader = command.ExecuteReader();
        if (reader.HasRows)
        {
            while (reader.Read())
            {
                return reader.GetInt32("upgradeLevel");
            }
        }
        return 1;
    }
    public int getUserCredits(string userName)
    {
        GD.Print("C# getUserCredits() - trying to get the credit balance of " + userName);
        int creditsAmount = 0;
        string query = $"SELECT credits FROM player WHERE username = '{userName}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = query;
        MySqlDataReader reader = command.ExecuteReader();
        if (reader.HasRows)
        {
            while (reader.Read())
            {
                creditsAmount = reader.GetInt32("credits");
            }
            reader.Close();
        }
        else
        {
            reader.Close();
        }
        connection.Close();
        GD.Print("C# getUserCredits() - the credit balance of " + userName + " is " + creditsAmount.ToString());
        return creditsAmount;
    }

    public int GetWeaponPrice(string weaponType)
    {
        string query = $"SELECT purchaseprice from weapon where weapontype = '{weaponType}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = query;
        MySqlDataReader reader = command.ExecuteReader();
        int price = 0;
        if (reader.HasRows)
        {
            while (reader.Read())
            {
                price = reader.GetInt32("purchaseprice");
            }
            reader.Close();
            connection.Close();
            GD.Print($"C# script GetWeaponPrice - {weaponType} costs {price} credits");
            return price;
        }
        price = 9999;
        GD.Print($"C# script GetWeaponPrice - {weaponType} costs {price} credits");
        return price;
    }

    public void updateUserCredits(string username, int credits)
    {
        string awardQuery = $"UPDATE player SET credits = {credits} WHERE username = '{username}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = awardQuery;
        command.ExecuteNonQuery();
        connection.Close();
        GD.Print($"{username}'s credit balance is now {credits}");
    }
    public bool CanBuyGun(string username, string gunType)
    {
        int credits = getUserCredits(username);
        int weaponPrice = GetWeaponPrice(gunType);
        if (credits >= weaponPrice)
        {
            GD.Print($"C# script CanBuyGun - {username} can buy {gunType}");
            return true;
        }
        else
        {
            GD.Print($"C# script CanBuyGun - {username} cannot buy {gunType}");
            return false;
        }
    }

    //Create a new weaponinstance for the user, and remove the weapon price from the user's credits.
    public void BuyGun(string username, string gunType)
    {
        GD.Print($"C# script BuyGun - {username} wants to buy {gunType}");
        int credits = getUserCredits(username); //get the user's credits
        int weaponPrice = GetWeaponPrice(gunType); //get the price of the weapon
        int newCredits = credits - weaponPrice; //substract gun price from credits
        string instanceID = username + gunType; //create the id for the weapon

        //query to create the "ownership" for the gun
        string weaponInstanceQuery = "INSERT INTO weaponInstance (weaponowner, weapontype, destroyedrobots, instanceid, weaponname) " +
            $"VALUES ('{username}', '{gunType}', 0, '{instanceID}', '{gunType}')";
        //query to update usercredits
        string playerQuery = $"UPDATE player SET credits = {newCredits} WHERE username = '{username}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        GD.Print($"C# script BuyGun - executing query '{weaponInstanceQuery}'");
        command.CommandText = weaponInstanceQuery;
        command.ExecuteNonQuery();

        GD.Print($"C# script BuyGun - executing query '{playerQuery}'");
        command.CommandText = playerQuery;
        command.ExecuteNonQuery();
        connection.Close();

        //After creating gun ownership, gotta add lvl 1 upgrades
        AddBaseUpgrades(username, gunType);
    }

    //Each weaponupgrade has a unique integer id to differentiate them
    //bulletDamage = 1
    //firerate = 2
    //magazineSize = 3
    //reloadSpeed = 4
    public bool CanBuyUpgrade(string username, string gunType, int upgradeID)
    {
        int credits = getUserCredits(username);
        string weaponAbbreviation = getWeaponAbbreviation(gunType);
        string upgradeInstanceID = username + weaponAbbreviation + upgradeID.ToString();
        int upgradePrice = GetUpgradePrice(upgradeInstanceID);
        if (credits >= upgradePrice)
        {
            GD.Print($"C# script CanBuyGun - {username} can buy {upgradeID}");
            return true;
        }
        else
        {
            GD.Print($"C# script CanBuyGun - {username} cannot buy {upgradeID}");
            return false;
        }
    }

    private void BuyUpgrade(string username, string gunType, int upgradeID)
    {
        int credits = getUserCredits(username);
        string weaponabbreviation = getWeaponAbbreviation(gunType);
        string upgradeInstanceID = username + weaponabbreviation + upgradeID.ToString();
        int currentUpgradeLevel = GetWeaponUpgradeLvl(username, gunType, upgradeID);
        int upgradePrice = GetUpgradePrice(upgradeInstanceID);
        string purchaseQuery = $"UPDATE weaponupgrade SET upgradelevel = {currentUpgradeLevel += 1}, upgradeprice = {upgradePrice + 100} WHERE upgradeid = '{upgradeInstanceID}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        GD.Print($"C# script BuyUpgrade - executing query '{purchaseQuery}'");
        command.CommandText = purchaseQuery;
        command.ExecuteNonQuery();
        string removeCreditsQuery = $"UPDATE player SET credits = {credits - upgradePrice} WHERE username = '{username}'";
        command.CommandText = removeCreditsQuery;
        GD.Print($"C# script BuyUpgrade - executing query '{removeCreditsQuery}'");
        command.ExecuteNonQuery();
        connection.Close();
    }
    public int GetUpgradePrice(string upgradeID)
    {
        GD.Print("C# GetUpgradePrice() - trying to get the price of " + upgradeID);
        string query = $"SELECT upgradePrice from weaponupgrade where upgradeId = '{upgradeID}'";
        connection = new MySqlConnection(connectionString);
        connection.Open();
        MySqlCommand command = connection.CreateCommand();
        command.CommandText = query;
        MySqlDataReader reader = command.ExecuteReader();
        int price = 0;
        if (reader.HasRows)
        {
            while (reader.Read())
            {
                price = reader.GetInt32("upgradePrice");
            }
            reader.Close();
            connection.Close();
            GD.Print($"C# script GetUpgradePrice - {upgradeID} costs {price} credits");
            return price;
        }
        price = 9999;
        GD.Print($"C# script GetUpgradePrice - {upgradeID} costs {price} credits");
        return price;
    }
}
