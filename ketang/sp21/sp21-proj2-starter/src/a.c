for (int i = 0; i < N; i ++) {
    if (m[i] > t) {
        t = m[i];
        r = i;
    }
    return i;
}
