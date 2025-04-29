from django.shortcuts import render, redirect, get_object_or_404
from django.http import HttpResponse
import base64
from .models import Post
import markdown
from django.utils.safestring import mark_safe

# Basic authentication credentials
EDIT_USERNAME = "admin"
EDIT_PASSWORD = "admin123"  # Change this!

def index(request):
    posts = Post.objects.all().order_by('-created_at')
    return render(request, 'index.html', {'posts': posts})

def post(request, pk):
    post = get_object_or_404(Post, id=pk)
    html_content = markdown.markdown(post.body)
    return render(request, 'posts.html', {
        'post': post,
        'html_content': mark_safe(html_content),
        'show_edit': request.GET.get('edit_key') == "admin123"
    })

def edit_post(request, pk):
    # Basic HTTP authentication check
    if not (request.headers.get('Authorization') == f'Basic {base64.b64encode(f"{EDIT_USERNAME}:{EDIT_PASSWORD}".encode()).decode()}'):
        return HttpResponse(status=401, headers={'WWW-Authenticate': 'Basic realm="Edit Access"'})
    
    post = get_object_or_404(Post, id=pk)
    
    if request.method == "POST":
        post.title = request.POST['title']
        post.body = request.POST['body']
        post.save()
        return redirect('post', pk=post.id)
    
    return render(request, 'edit_post.html', {'post': post})