/**
 * RoleCheck
 *
 * Show chunks based on User's role
 * 
 * @author    Nicola Lambathakis http://www.tattoocms.it/
 * @category    snippet
 * @version    1.0.1
 * @internal @modx_category Users
 * @lastupdate  23-11-2024
 */

// call: [!RoleCheck? &roles=`WebUsers` &YesChunk=`WelcomeUser` &NoChunk=`YouAreNotLogged`!]
// Snippet parameters
$roles = isset($roles) ? explode(',', $roles) : [];        // List of roles to compare
$YesChunk = isset($YesChunk) ? $YesChunk : '';            // Name of the chunk or HTML to display if the user is authorized
$NoChunk = isset($NoChunk) ? $NoChunk : '';               // Name of the chunk or HTML to display if the user is not authorized or not logged in

// Retrieve the ID of the currently logged-in user
$EVOuserId = evolutionCMS()->getLoginUserID();
$userId = isset($userId) ? (string)$userId : $EVOuserId;

// Check if the function already exists to avoid redeclaration
if (!function_exists('renderChunkOrHtml')) {
    function renderChunkOrHtml($value) {
        if (strpos($value, '@CODE:') === 0) {
            return substr($value, 6); // Removes '@CODE:' and returns the HTML code
        } else {
            return evolutionCMS()->getChunk($value); // Returns the chunk
        }
    }
}

// Check if the user is logged in and belongs to one of the roles
$authorized = false;

if ($userId && $userId > 0) {
    try {
        // Get user details via UserManager
        $user = \UserManager::get($userId);

        // Retrieve the role number
        $userRoleId = $user->attributes->role ?? null;

        if ($userRoleId) {
            // Query to get the role name from the user_roles table
            $query = evolutionCMS()->db->select(
                'name',               // Column to select
                '[+prefix+]user_roles', // user_roles table with prefix
                "id = '{$userRoleId}'" // Condition for the role ID
            );

            // Retrieve the role name
            $roleName = evolutionCMS()->db->getValue($query);

            // Check if the role is in the list
            if ($roleName && in_array($roleName, $roles)) {
                $authorized = true;
            }
        }
    } catch (\Exception $e) {
        // Error handling (can be logged if necessary)
    }
}

// Display the appropriate chunk or HTML
echo $authorized ? renderChunkOrHtml($YesChunk) : renderChunkOrHtml($NoChunk);
