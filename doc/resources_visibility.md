## Access to resources dependend from setting

## Backend
### Galleries
  owner: view all galleries
  user with read permission: view all gallery regardless of settings
  user without read permission: view no gallery regardless of settings
### Folders
  owner: view all folders
  user with read permission: view all folders regardless of settings
  user without read permission: view no folders regardless of settings

## Frontend
### Galleries
  account owner:
    - invisible gallery don't shows on front-end
    - view all other galleries
  sub-user with read permission:
    - can view all public folders
    - can view galleries with given access
    * - can view protected by password/credentialed galleries [ if have read for them ]
    * - can request protected by password/credentialed galleries [ if havent read access for them ]
  guest
    - can't view invisible galleries
    - can't request credentialing [ as not logged, he can't send invite ]
    - can view protected by password/credentialed galleries [ with correct password only ]
    - can view all public folders

### Folders
  account owner
    - invisible folders and assets dont showing on front-end
    - can view password protected folders & with assets
  sub-user
    - invisible folders and assets dont showing on front-end
    - can view password protected folders & with assets if have read_permission
    - can view password protected folders & with aassets if have correct password

  guest user
    - invisible folders and assets dont showing on front-end
    - can view password protected folders & with assets only if have correct password
