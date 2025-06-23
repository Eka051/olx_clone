import java.io.FileInputStream
import java.util.Properties

// Read .env file and get GMAPS_API_KEY
val envFile = file("../../.env")
val envProps = Properties()

if (envFile.exists()) {
    FileInputStream(envFile).use { stream ->
        envProps.load(stream)
    }
}

val gmapsApiKey = envProps.getProperty("GMAPS_API_KEY", "")

android {
    // ... existing configuration ...
    
    defaultConfig {
        // ... existing defaultConfig ...
        
        manifestPlaceholders = mapOf(
            "GMAPS_API_KEY" to gmapsApiKey
        )
    }
}
