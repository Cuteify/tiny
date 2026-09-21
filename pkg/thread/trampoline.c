/* pkg/thread/trampoline.c — C thread entry wrapper for Cuteify */
typedef void*(*thread_fn)(void*);

typedef struct {
    thread_fn func;
    void* arg;
    void* retval;
} ThreadCtx;

void* cute_thread_entry(void* ctx_ptr) {
    ThreadCtx* ctx = (ThreadCtx*)ctx_ptr;
    ctx->retval = ctx->func(ctx->arg);
    return ctx->retval;
}
