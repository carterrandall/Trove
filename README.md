# Trove
AR Persistent Hidden Message App

![banner](https://github.com/carterrandall/Trove/blob/master/images/trovebanner.png)

### About: 
Trove Saves notes in 3D space around you. Create custom 3D objects and anchor them to real world objects and locations. When you save a note, other users in the area will see that a note is hidden there. By pointing their camera at the scene where you left a note the 3D object is relocalized to the visible planes in the camera. GPS location is too imprecise to recreate the note in the exact location you left it. Trove overcomes this by saving a visual map of planes of the objects in your surroundings.

## Leave a note

![create](https://github.com/carterrandall/Trove/blob/master/images/create.png)

## Others in the area can see the note you left behind!
![relocalize](https://github.com/carterrandall/Trove/blob/master/images/relocalize.png)

### Required Pods:

* Firebase v5.4
* Firebase Storage
* Firestore
* Geofirestore

### Setup:

1. Create a firebase project with a firestore database and storage instance. 
2. Copy the GoogleServiceInfo.plist into your project
3. pod init and install the pods listed above.
