import { useForm } from 'react-hook-form'
import { z } from 'zod'
import { zodResolver } from '@hookform/resolvers/zod'
import { useLogin } from '../hooks'

const schema = z.object({ email: z.string().email(), password: z.string().min(3) })
type Form = z.infer<typeof schema>

export default function LoginPage() {
    const { register, handleSubmit, formState: { errors } } = useForm<Form>({ resolver: zodResolver(schema) })
    const { mutateAsync, isPending } = useLogin()

    return (
        <div className="mx-auto max-w-sm p-6">
            <h1 className="text-2xl font-semibold mb-4">Login</h1>
            <form onSubmit={handleSubmit(async (v) => await mutateAsync(v))} className="space-y-3">
                <input className="w-full border rounded px-3 py-2" placeholder="Email" {...register('email')} />
                {errors.email && <p className="text-red-600 text-sm">{errors.email.message}</p>}
                <input className="w-full border rounded px-3 py-2" type="password" placeholder="Password" {...register('password')} />
                {errors.password && <p className="text-red-600 text-sm">{errors.password.message}</p>}
                <button className="w-full rounded px-3 py-2 bg-blue-600 text-white hover:bg-blue-700" disabled={isPending}>Login</button>
            </form>
        </div>
    )
}
