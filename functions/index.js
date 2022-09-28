import { firestore } from "firebase-functions";
import { initializeApp, firestore as _firestore } from 'firebase-admin';
initializeApp();

export const onCreateFollowing = firestore
    .document("/following/{userId}/userFollowing/{followingId}")
    .onCreate(async (snapshot, context) => {
        console.log("Follower Created", snapshot.data());
        const userId = context.params.userId;
        const followingId = context.params.followingId;

        // 1) Creata Followed Users Posts (doctor) Ref
        const followingUserPostsRef = _firestore()
            .collection('posts')
            .document(followingId)
            .collection('userPosts');

        // 2) Create User's NewsFeed Ref
        const newsfeedPostsRef = _firestore()
            .collection('newsfeed')
            .document(userId)
            .collection('newsfeedPosts')

        // 3) Get Following User Posts
        const querySnapshot = await followingUserPostsRef.get();

        // 4) Add each doctor posts to the following user's newsfeed
        querySnapshot.forEach(document => {
            if (document.exists) {
                const postId = document.id;
                const postData = document.data();
                newsfeedPostsRef.document(postId).set(postData);
            }
        })
    });