using Microsoft.EntityFrameworkCore;
using PhysicsBook.Models;

namespace PhysicsBook.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<Book> Books => Set<Book>();
    public DbSet<Chapter> Chapters => Set<Chapter>();
    public DbSet<Lesson> Lessons => Set<Lesson>();
    public DbSet<Question> Questions => Set<Question>();
    public DbSet<Progress> Progresses => Set<Progress>();
    public DbSet<Badge> Badges => Set<Badge>();
    public DbSet<UserBadge> UserBadges => Set<UserBadge>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>(e =>
        {
            e.HasIndex(u => u.Email).IsUnique();
        });

        modelBuilder.Entity<Progress>(e =>
        {
            e.ToTable("Progress");
            e.HasIndex(p => p.UserId);
            e.HasIndex(p => p.LessonId);
            e.HasOne(p => p.User).WithMany(u => u.Progresses).HasForeignKey(p => p.UserId);
            e.HasOne(p => p.Lesson).WithMany(l => l.Progresses).HasForeignKey(p => p.LessonId);
        });

        modelBuilder.Entity<UserBadge>(e =>
        {
            e.HasIndex(ub => new { ub.UserId, ub.BadgeId }).IsUnique();
            e.HasOne(ub => ub.User).WithMany(u => u.UserBadges).HasForeignKey(ub => ub.UserId);
            e.HasOne(ub => ub.Badge).WithMany(b => b.UserBadges).HasForeignKey(ub => ub.BadgeId);
        });

        modelBuilder.Entity<Chapter>(e =>
        {
            e.HasOne(c => c.Book).WithMany(b => b.Chapters).HasForeignKey(c => c.BookId);
            e.HasIndex(c => c.BookId);
        });

        modelBuilder.Entity<Lesson>(e =>
        {
            e.HasOne(l => l.Chapter).WithMany(c => c.Lessons).HasForeignKey(l => l.ChapterId);
            e.HasIndex(l => l.ChapterId);
        });

        modelBuilder.Entity<Question>(e =>
        {
            e.HasOne(q => q.Lesson).WithMany(l => l.Questions).HasForeignKey(q => q.LessonId);
            e.HasIndex(q => q.LessonId);
        });
    }
}

